---
name: pavlenko-flutter-feature
description: Build or change Flutter features in Aleksandr Pavlenko's preferred feature-first architecture. Use for new screens, repositories, remote sources, controllers, BLoCs, route parameters, dependency wiring, scanner-driven flows, or refactoring an existing Flutter feature. Enforces reuse-first design, typed boundaries, sealed BLoC states/events, explicit concurrency, and project-consistent error handling.
metadata:
  author: OpenCode for Aleksandr Pavlenko
  version: "1.0"
---

# Flutter Feature Architecture

## Goal

Write the smallest correct change that looks native to the repository. Existing architecture and reusable components take precedence over this skill's defaults.

## Mandatory Workflow

1. Inspect repository guidance, analyzer configuration, nearby features, shared code, routing, and dependency registration before proposing code.
2. Find at least one feature with similar behavior and adapt it. Search especially for an existing shared process before adding abstractions.
3. State the intended ownership of UI, orchestration, business logic, network calls, and models.
4. Implement the minimum complete vertical slice.
5. Format, analyze, and test with repository-provided commands. Fix warnings instead of suppressing them.

Do not introduce compatibility layers, generic base classes, service locators, or new state-management libraries without a concrete requirement.

## Preferred Feature Shape

Use this shape when the repository does not already dictate another one:

```text
feature_name/
  main.dart
  bloc/
    bloc.dart
    event.dart
    state.dart
  domain/
    repository.dart
    route_params.dart
  data/
    repository_impl.dart
    remote_source.dart
    remote_source_impl.dart
  widgets/
    screen.dart
```

Add files only when they carry real responsibility. A local-only flow may not need `data` or a repository. A reusable long-lived workflow may justify a controller.

## Layer Responsibilities

### `main.dart`

- Name the entry widget `XxxMain`.
- Treat it as the feature composition root.
- Wire `RemoteSourceImpl -> RepositoryImpl -> Bloc` locally unless the dependency is application-wide.
- Send the initial event through a cascade in `BlocProvider.create` when possible.
- Keep scanner and hardware-provider orchestration around the feature here.
- Use `StatefulWidget` only for lifecycle, controllers, subscriptions, or callbacks that need a stable BLoC reference.

### Domain

- Define contracts as `abstract interface class`.
- Keep route arguments typed in `XxxParams`; never pass raw maps.
- Do not import widgets, `main.dart`, transport clients, or data-layer implementations into domain code.
- Prefer domain models at repository boundaries. Keep `dynamic` and raw JSON out of UI and BLoC.

### Data

- A remote source owns endpoints, query/body construction, request options, and raw payload extraction.
- A repository owns conversion from wire data to typed models.
- Feature code must not parse Dio exceptions or HTTP status codes when the shared network layer already maps them.
- Use existing payload converters and model utilities before writing another converter.

### Controller

Add a controller only for a long-lived process coordinating several repositories, storage, streams, device APIs, or session state. Do not add a controller as a pass-through layer.

## BLoC Contract

Use one library with parts:

```dart
part 'event.dart';
part 'state.dart';
```

```dart
sealed class const OrdersEvent();

final class const OrdersLoadEvent() extends OrdersEvent;
```

```dart
sealed class const OrdersState();

final class const OrdersLoadingState() extends OrdersState;
final class const OrdersLoadedState({required final Orders data})
    extends OrdersState;
final class const OrdersErrorState() extends OrdersState;
```

- Register one event handler and route variants with an exhaustive switch.
- Choose concurrency explicitly:
  - `sequential()` when order matters, especially network mutations and normal feature events.
  - `droppable()` when repeated hardware scans during an active operation must be ignored.
  - Use another transformer only after demonstrating why these two are wrong.
- Type-guard the current state before reading variant-specific fields.
- Preserve usable prior data after refresh/mutation errors when that matches the UX. Mark stale data explicitly if the feature does so.
- Keep navigation, modals, and toasts out of builders and business handlers unless the established project architecture routes them through global error infrastructure.

Preferred error handling:

```dart
try {
  final Orders data = await _repository.load();
  emit(OrdersLoadedState(data: data));
} on Object catch (error, stackTrace) {
  addError(error, stackTrace);
  emit(const OrdersErrorState());
}
```

Do not `throw` from a BLoC handler when `addError` is the project's global reporting path. Do not silently swallow business failures.

## Dependency Injection

- Put long-lived infrastructure in the application container: network clients, storage, device clients, global streams, sessions, and global controllers.
- Construct ordinary feature repositories and BLoCs in the feature entry point.
- Consume inherited dependencies through the existing scope rather than adding another DI framework.
- Global BLoCs are created once at application composition; feature screens must read them rather than create duplicate instances.
- Respect ownership: the creator closes a BLoC, subscription, controller, or stream.

## Routing

- Register routes in the central router.
- Expose navigation through the repository's navigation facade/helper.
- Use `XxxParams` for every nontrivial argument.
- Preserve platform-specific route transitions already implemented by the router.
- After navigation or modal `await`, check `context.mounted` before using context.
- If a retained BLoC is used after `await`, also verify it is not closed.

## Scanner and Hardware Flows

- Wrap the whole feature with the established scanner provider; do not mount it inside a changing BLoC-state branch.
- Keep barcode classification, confirmation before replacing the current object, and route-aware subscription management at the feature boundary.
- Put business transitions caused by a scan in BLoC events.
- Ensure only the visible route owns an active scanner subscription.
- Handle hardware keyboard `KeyDownEvent`, terminal capability checks, and platform restrictions through existing device abstractions.

## Reuse Checklist

Before creating code, search for:

- a similar feature composition root;
- an existing shared collection/selection/input flow;
- repository and remote-source contracts;
- route and modal helpers;
- typed network payload accessors;
- shared converters, notifiers, scanner providers, and device capability APIs;
- existing error, loading, and stale-data behavior.

If a nearby implementation has an apparent defect or layer violation, do not copy it merely for consistency. Follow the dominant pattern and improve only code required by the task.

## Completion Checklist

- Feature follows local naming and folder conventions.
- No unnecessary layer or abstraction was introduced.
- Domain does not depend on UI/data implementation details.
- Events and states are closed, typed, and exhaustively handled.
- Concurrency semantics are explicit.
- Errors retain stack traces and reach established reporting.
- Route arguments and network boundaries are typed.
- Async lifecycle and ownership are correct.
- Formatting, analyzer, and relevant tests pass.
