---
name: pavlenko-dart-style
description: Write and review Dart code in Aleksandr Pavlenko's preferred strict style. Use for any Dart implementation, refactor, model, service, repository, stream, serialization, networking, or analyzer cleanup. Favors modern Dart, immutable typed APIs, package imports, exhaustive patterns, explicit async/error semantics, and zero lint suppressions.
metadata:
  author: OpenCode for Aleksandr Pavlenko
  version: "1.0"
---

# Preferred Dart Style

## Priority Order

1. Repository instructions and analyzer rules.
2. Dominant style in the files being changed.
3. Existing reusable APIs and public package boundaries.
4. Defaults in this skill.

Never weaken analysis or add `ignore` directives to make code pass. Fix the cause. A suppression is acceptable only for a demonstrated framework lifecycle constraint and must explain why.

## Modern Type Design

- Use `abstract interface class` for contracts.
- Use `final class` for implementations and values not designed for inheritance.
- Use `sealed class` for closed event, state, exception, and result hierarchies.
- Use `sealed class` as a static namespace only when the repository already follows that pattern.
- Prefer `const` constructors and `final` fields.
- Use `late final` only when framework lifecycle makes immediate construction impossible.
- Express absence with nullable types, not magic values.
- Keep public and layer-boundary return types explicit.

Preferred naming:

- files/directories: `snake_case`;
- types/extensions: `UpperCamelCase`;
- members/locals/constants/enum values: `lowerCamelCase`;
- contracts: `XxxRepository`, `XxxController`, `XxxRemoteSource`;
- implementations: `XxxRepositoryImpl`, `XxxControllerImpl`, `XxxRemoteSourceImpl`.

For new code, use `FeatureLoadedState`, not legacy `$`-separated names. Preserve an established local naming family when making a narrow change.

## Variables and Constructors

- Default to `final`, not `var`.
- Add an explicit local type at JSON, async, generic, and architectural boundaries.
- Type inference is fine when the right-hand side is obvious.
- Make immutable widgets and values `const` when possible.
- Do not make collections mutable unless mutation is part of the object's responsibility.
- Do not add `copyWith`, equality, or `toJson` mechanically; add only behavior with a caller.
- If `copyWith` must set a nullable field to `null`, do not use a simple `value ?? this.value` implementation. Use an explicit sentinel or dedicated operation.

## Imports and Libraries

- Order imports as `dart:*`, blank line, then `package:*`.
- Use package imports for application code when analyzer rules require them.
- Consume workspace packages through their public barrel file, not `package:x/src/...`.
- Use relative paths for `part` and `part of`.
- Restrict exports with `show` when only a narrow API is public.
- Do not export implementation details merely to simplify one import.

## Null Safety and Patterns

- Check type/null, allow promotion, and return early.
- Use `!` only for an invariant already proven in the same flow.
- At JSON boundaries, validate runtime shape before casting optional nested values.
- Prefer exhaustive switch expressions over default branches for enums and sealed hierarchies.
- Avoid catch-all switch cases that hide newly added variants.
- Use records, destructuring, collection-if, and spreads when they simplify code without obscuring types.

## Async and Error Semantics

- Return concrete `Future<T>` and `Stream<T>` types.
- Await asynchronous work unless fire-and-forget is intentional.
- Mark intentional fire-and-forget with `unawaited(...)` or the repository's accepted equivalent.
- Catch `Object` with stack trace at broad application boundaries:

```dart
} on Object catch (error, stackTrace) {
  // Report or convert while retaining stackTrace.
}
```

- Catch a narrow exception only when behavior depends on its type.
- Use `rethrow` to preserve the original stack trace.
- Empty catches are allowed only for clearly best-effort teardown/audio/disconnect work; add a short comment if intent is not obvious.
- Put mandatory cleanup in `finally`.
- Make async close/dispose idempotent when it may be called more than once.

## Streams and Lifecycle

- Keep `StreamController` private; expose only `Stream<T>` and/or `Sink<T>`.
- Use broadcast streams only when multiple listeners are required.
- Use the project's replay/repeat-latest abstraction instead of inventing another one.
- Store every subscription that outlives a local method and cancel it at ownership teardown.
- Close controllers owned by the object.
- Never hold a `BuildContext` in a long-lived service.

## Serialization

- Keep `dynamic` at JSON/wire boundaries only.
- Parse required fields strictly so malformed server responses fail visibly.
- Check optional nested objects with `is Map<String, dynamic>` before conversion.
- Use shared typed list converters before writing loops.
- Use `List<T>.from(...)` for primitive lists where valid.
- Convert incoming server timestamps consistently, including `.toLocal()` if that is the application convention.
- Add `toJson` only to values actually sent or persisted.
- Do not silently fabricate defaults for required server fields.

## Networking

- Shared client owns transport, interceptors, retries, and transport exception mapping.
- Remote source owns endpoint, query/body, request options, and raw payload extraction.
- Repository owns mapping raw payloads into typed models.
- UI and BLoC must not parse HTTP statuses or depend on Dio.
- Prefer `Map<String, Object?>` for outbound body/query data.
- Use `Map<String, dynamic>`, `List<dynamic>`, or `Object?` only at inbound serialization boundaries.
- Use established typed payload getters rather than repeated casts.
- Pass loader/request options through every layer without accidentally dropping them.

## Formatting

- Use the repository's pinned Dart/Flutter formatter.
- Two-space indentation and single quotes.
- Add trailing commas to multiline declarations and calls.
- Prefer expression bodies for short forwarding methods only.
- Keep one function until extraction provides meaningful reuse, composition, or readability.
- Comments explain non-obvious intent or constraints, never restate syntax.
- Use ASCII unless the file or user-facing localized content requires Unicode.

## Review Checklist

- Analyzer has no warnings and no new suppressions.
- API and layer boundaries have explicit types.
- Mutability and nullability are intentional.
- All sealed variants are handled exhaustively.
- Futures, streams, subscriptions, and controllers have clear ownership.
- Errors preserve stack traces and are neither swallowed nor double-reported.
- JSON cannot leak into domain/UI.
- Existing utilities and public package APIs are reused.
- The diff is smaller than alternative correct designs.
