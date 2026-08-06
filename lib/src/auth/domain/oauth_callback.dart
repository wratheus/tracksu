sealed class OAuthCallbackResult {
  const OAuthCallbackResult();
}

final class OAuthAuthorizationCodeCallback extends OAuthCallbackResult {
  const OAuthAuthorizationCodeCallback({
    required this.code,
    required this.state,
  });

  final String code;
  final String state;
}

final class OAuthAuthorizationErrorCallback extends OAuthCallbackResult {
  const OAuthAuthorizationErrorCallback({
    required this.error,
    required this.state,
  });

  final String error;
  final String state;
}

final class OAuthRejectedCallback extends OAuthCallbackResult {
  const OAuthRejectedCallback();
}

final class OAuthCallbackParser {
  const OAuthCallbackParser();

  static const callbackUri = 'https://wratheus.github.io/oauth/osu/callback/';
  static const _scheme = 'https';
  static const _host = 'wratheus.github.io';
  static const _path = '/oauth/osu/callback/';

  OAuthCallbackResult parse(Uri uri) {
    if (!_isExpectedCallbackUri(uri)) {
      return const OAuthRejectedCallback();
    }

    final List<String>? codeValues = uri.queryParametersAll['code'];
    final List<String>? errorValues = uri.queryParametersAll['error'];
    final String? state = _singleNonEmptyParameter(uri, 'state');

    if (state == null || (codeValues != null && errorValues != null)) {
      return const OAuthRejectedCallback();
    }

    if (codeValues != null) {
      final String? code = _singleNonEmptyParameter(uri, 'code');
      if (code == null) {
        return const OAuthRejectedCallback();
      }

      return OAuthAuthorizationCodeCallback(code: code, state: state);
    }

    if (errorValues != null) {
      final String? error = _singleNonEmptyParameter(uri, 'error');
      if (error == null) {
        return const OAuthRejectedCallback();
      }

      return OAuthAuthorizationErrorCallback(error: error, state: state);
    }

    return const OAuthRejectedCallback();
  }

  bool _isExpectedCallbackUri(Uri uri) {
    return uri.scheme == _scheme &&
        uri.host == _host &&
        uri.path == _path &&
        uri.userInfo.isEmpty &&
        uri.fragment.isEmpty;
  }

  String? _singleNonEmptyParameter(Uri uri, String name) {
    final List<String>? values = uri.queryParametersAll[name];
    if (values == null || values.length != 1 || values.single.isEmpty) {
      return null;
    }

    return values.single;
  }
}
