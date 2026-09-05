import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:tracksu/src/auth/domain/authorization.dart';
import 'package:tracksu/src/auth/domain/auth_repository.dart';
import 'package:tracksu/src/auth/domain/oauth_callback.dart';
import 'package:tracksu/src/auth/domain/oauth_callback_link_source.dart';

part 'event.dart';
part 'state.dart';

final class AuthorizationBloc
    extends Bloc<AuthorizationEvent, AuthorizationState> {
  factory AuthorizationBloc({
    required AuthorizationRepository repository,
    required AuthRepository authRepository,
    required OAuthCallbackLinkSource callbacks,
  }) => AuthorizationBloc._(repository, authRepository, callbacks);
  AuthorizationBloc._(this._repository, this._authRepository, this._callbacks)
    : super(const AuthorizationIdleState()) {
    // Concurrent: callbacks/lifecycle must not wait behind browser launch.
    // Preparing/completing guards and generation checks protect async transitions.
    on<AuthorizationEvent>(_onEvent);
  }
  final AuthorizationRepository _repository;
  final AuthRepository _authRepository;
  final OAuthCallbackLinkSource _callbacks;
  final OAuthCallbackParser _parser = const OAuthCallbackParser();
  StreamSubscription<Uri>? _subscription;
  Timer? _timer;
  String? _expectedState;
  int _generation = 0;
  bool _closing = false;
  bool get _inactive => _closing || isClosed;
  bool _started = false;
  bool _leftApp = false;
  bool _failing = false;

  void _enqueue(AuthorizationEvent event) {
    if (!_inactive) add(event);
  }

  Future<void> _onEvent(
    AuthorizationEvent event,
    Emitter<AuthorizationState> emit,
  ) async {
    if (_inactive) return;
    switch (event) {
      case AuthorizationStarted(:final params):
        if (_started) return;
        _started = true;
        _subscription = _callbacks.uriStream.listen(
          (Uri uri) => _enqueue(_CallbackReceived(uri)),
          onError: (Object error, StackTrace stackTrace) =>
              _enqueue(const _CallbackFailed()),
        );
        if (params.initialCallbackUri case final Uri uri) {
          emit(const AuthorizationPreparingState());
          try {
            final String? expected = await _repository.restoreState();
            if (_inactive || emit.isDone) return;
            if (expected == null) {
              await _fail(AuthorizationFailure.expired, emit);
              return;
            }
            if (_parser.parse(uri) is OAuthRejectedCallback) {
              await _fail(AuthorizationFailure.invalidResponse, emit);
              return;
            }
            _expectedState = expected;
            emit(const AuthorizationWaitingState());
            await _receive(uri, emit);
          } on Object catch (_, stackTrace) {
            if (_inactive || emit.isDone) return;
            addError(AuthorizationFailure.responseUnavailable, stackTrace);
            await _fail(AuthorizationFailure.responseUnavailable, emit);
          }
        } else if (params.startOnOpen) {
          await _start(emit);
        }
      case AuthorizationRequested():
        await _start(emit);
      case _CallbackReceived(:final uri):
        await _receive(uri, emit);
      case _CallbackFailed():
        if (state is AuthorizationWaitingState && !_failing) {
          await _fail(AuthorizationFailure.responseUnavailable, emit);
        }
      case AuthorizationLeftApp():
        if (state is AuthorizationWaitingState) {
          _leftApp = true;
          _timer?.cancel();
        }
      case AuthorizationReturned():
        if (!_leftApp || state is! AuthorizationWaitingState || _failing) {
          return;
        }
        _leftApp = false;
        final int generation = _generation;
        _timer?.cancel();
        _timer = Timer(
          const Duration(seconds: 2),
          () => _enqueue(_ReturnTimedOut(generation)),
        );
      case _ReturnTimedOut(:final generation):
        if (generation == _generation &&
            state is AuthorizationWaitingState &&
            !_failing) {
          await _fail(AuthorizationFailure.incomplete, emit);
        }
    }
  }

  Future<void> _start(Emitter<AuthorizationState> emit) async {
    if (_failing ||
        (state is! AuthorizationIdleState &&
            state is! AuthorizationFailureState)) {
      return;
    }
    final int generation = ++_generation;
    _leftApp = false;
    emit(const AuthorizationPreparingState());
    final AuthorizationAttempt attempt;
    try {
      attempt = await _repository.prepare();
    } on Object catch (_, stackTrace) {
      if (_inactive || emit.isDone) return;
      addError(AuthorizationFailure.preparation, stackTrace);
      await _fail(AuthorizationFailure.preparation, emit);
      return;
    }
    if (_inactive || emit.isDone || generation != _generation) return;
    _expectedState = attempt.state;
    emit(const AuthorizationWaitingState());
    try {
      final bool opened = await _repository.openBrowser(attempt.uri);
      if (!opened &&
          !_inactive &&
          !emit.isDone &&
          generation == _generation &&
          state is AuthorizationWaitingState) {
        await _fail(AuthorizationFailure.launch, emit);
      }
    } on Object catch (_, stackTrace) {
      if (_inactive ||
          emit.isDone ||
          generation != _generation ||
          state is! AuthorizationWaitingState) {
        return;
      }
      addError(AuthorizationFailure.launch, stackTrace);
      await _fail(AuthorizationFailure.launch, emit);
    }
  }

  Future<void> _receive(Uri uri, Emitter<AuthorizationState> emit) async {
    if (_failing ||
        state is! AuthorizationWaitingState ||
        _expectedState == null) {
      return;
    }
    final Uri target = Uri.parse(OAuthCallbackParser.callbackUri);
    // Unrelated app links cannot cancel an in-progress authorization.
    if (uri.scheme != target.scheme ||
        uri.host != target.host ||
        uri.port != target.port ||
        uri.path != target.path) {
      return;
    }
    final OAuthCallbackResult callback = _parser.parse(uri);
    _timer?.cancel();
    switch (callback) {
      case OAuthAuthorizationCodeCallback(:final code, :final state):
        if (state != _expectedState) {
          await _fail(AuthorizationFailure.mismatch, emit);
          return;
        }
        emit(const AuthorizationCompletingState());
        _leftApp = false;
        try {
          await _authRepository.exchangeAuthorizationCode(code: code);
          if (_inactive || emit.isDone) return;
          await _repository.clear();
          if (_inactive || emit.isDone) return;
          _expectedState = null;
          emit(const AuthorizationSuccessState());
        } on Object catch (_, stackTrace) {
          if (_inactive || emit.isDone) return;
          addError(AuthorizationFailure.completion, stackTrace);
          await _fail(AuthorizationFailure.completion, emit);
        }
      case OAuthAuthorizationErrorCallback(:final state):
        await _fail(
          state == _expectedState
              ? AuthorizationFailure.cancelled
              : AuthorizationFailure.mismatch,
          emit,
        );
      case OAuthRejectedCallback():
        await _fail(AuthorizationFailure.invalidResponse, emit);
    }
  }

  Future<void> _fail(
    AuthorizationFailure failure,
    Emitter<AuthorizationState> emit,
  ) async {
    if (_inactive || emit.isDone || _failing) return;
    _failing = true;
    _generation++;
    _timer?.cancel();
    _expectedState = null;
    _leftApp = false;
    try {
      await _repository.clear();
    } on Object catch (_, stackTrace) {
      addError(AuthorizationFailure.preparation, stackTrace);
    } finally {
      _failing = false;
    }
    if (!_inactive && !emit.isDone) emit(AuthorizationFailureState(failure));
  }

  @override
  Future<void> close() async {
    _closing = true;
    _generation++;
    _timer?.cancel();
    await _subscription?.cancel();
    await super.close();
    // Keep a pending transaction: a browser callback may cold-start the app.
  }
}
