---
name: pavlenko-flutter-quality
description: Verify, test, and review Flutter/Dart changes to Aleksandr Pavlenko's quality bar. Use after implementation, when writing tests, fixing analyzer issues, reviewing a diff, investigating regressions, or preparing a Flutter change for handoff. Prioritizes behavior and architecture risks, targeted Mocktail tests, pinned FVM commands, generated-code discipline, and zero analyzer warnings.
metadata:
  author: OpenCode for Aleksandr Pavlenko
  version: "1.0"
---

# Flutter Quality Gate

## Purpose

Prove that the change is correct without inflating the implementation or creating test-only architecture. Match repository commands, test libraries, naming, and dependency boundaries.

## Verification Workflow

1. Inspect the diff and list behavior changed, including error, loading, empty, retry, concurrency, and lifecycle paths.
2. Add the smallest tests that would fail for the likely regressions.
3. Run generation only when generated inputs changed.
4. Format only changed Dart files using the pinned SDK.
5. Run static analysis and relevant targeted tests.
6. Run the broader test suite when feasible.
7. Re-read the final diff for accidental generated files, lint suppressions, unrelated formatting, dropped request options, or unclosed resources.

In repositories using FVM, always prefix Flutter/Dart commands with `fvm` unless the repository explicitly wraps them.

Typical TSD workflow:

```bash
make get
make gen
fvm dart format <changed-dart-files>
fvm flutter analyze
fvm flutter test
```

Do not run `make gen` without a generation-related change. If workspace packages have their own tests, run tests from those package directories as well.

## Test Selection

### Unit Tests

Use for:

- controllers and pure orchestration;
- validators, converters, and utilities;
- repositories and model parsing;
- date/language/config resolution;
- stream behavior and error conversion.

### BLoC Tests

Cover:

- initial event behavior;
- successful transitions;
- invalid-event guards for the current state;
- error state and preservation of previous/stale data;
- event ordering under `sequential()`;
- ignored duplicate work under `droppable()` where important;
- important repository calls and request options.

Do not assert private implementation details. Assert emitted behavior and externally meaningful interactions.

### Widget Tests

Use for:

- exhaustive loading/loaded/empty/error rendering;
- retry and primary actions;
- navigation/modal side effects;
- form trimming, submit behavior, and debounce boundaries;
- safe layout with keyboard/text scaling when relevant;
- lifecycle ownership when a regression is plausible.

Build widgets with the real project wrappers: dependency scope, localization, theme, navigator, and `BlocProvider`. Do not replace application structure with an unrelated test harness.

### Integration Tests

Reserve for critical multi-screen flows, scanner/hardware boundaries, authentication, route restoration, and plugin integration that cannot be trusted through unit/widget tests.

## Test Style

- Mirror `lib/src/...` under `test/src/...`.
- Use the repository's existing mocking library; in TSD-style projects, use `mocktail`.
- Keep a small mock next to its test. Extract helpers only after real reuse.
- Prefer behavior-oriented test names in the repository's language.
- Separate arrange, act, and assert with blank lines.
- Verify both result/state and important side effects with `verify`/`verifyNever`.
- Import workspace packages through public barrels.
- Avoid broad `pumpAndSettle()` when an animation/stream never settles; pump the precise duration/state instead.
- Do not add production APIs solely to make a test convenient unless testability exposes a genuine design boundary.
- Do not use lint suppressions for tests.

## High-Risk Review Areas

Review these before style details:

- Wrong state after an exception or retry.
- Concurrent events completing out of order.
- A request option accepted by repository but not forwarded to remote source.
- Domain importing data/UI implementation details.
- Duplicate BLoC, stream, scanner, or subscription ownership.
- Context or BLoC use after `await` without mounted/closed checks.
- Controllers, timers, focus nodes, stream controllers, or subscriptions not disposed.
- A scanner remaining active under another route.
- Raw JSON or `dynamic` leaking past repository boundaries.
- Required payload fields silently defaulted.
- Route arguments cast unsafely or passed as maps.
- Navigation/modal/toast triggered from a builder.
- Missing localization or theme-aware color.
- `SizedBox` used only as spacing.
- Added abstraction that has one caller and no real policy.

## Analyzer Discipline

- Treat every analyzer warning as a defect.
- Never disable corporate lint rules for environment convenience.
- Do not copy package-specific lint exceptions into application code.
- Do not edit generated code to fix analysis; fix the source or generation setup.
- Use public package APIs and package imports according to local lint rules.
- Intentional unawaited futures must be explicit.
- Preserve stack traces in error conversion/reporting.

## Generated Code

Run generation when changing localization sources, generator inputs, annotations, or configured generated metadata.

- Never hand-edit generated localization/model/config files.
- Confirm generated output contains only expected changes.
- If generation produces unrelated churn, investigate version/tool mismatch rather than committing noise.
- Use the Flutter/Dart version pinned by the repository.

## Code Review Output

When asked for a review:

1. Report findings first, ordered by severity.
2. Include file and line references.
3. Explain the concrete failure mode, not only the violated style rule.
4. Identify missing tests tied to a plausible regression.
5. Keep the summary secondary.
6. If no findings exist, say so and list residual test/verification gaps.

Do not manufacture findings to appear thorough.

## Completion Report

State:

- what behavior was implemented or verified;
- which files or architectural areas changed;
- exact checks run and whether they passed;
- tests added and behavior covered;
- anything not run and why.

Do not claim success from inspection alone when executable checks were available.

## Final Checklist

- Diff contains only intended changes.
- Existing architecture/components were adapted before anything new was created.
- Formatter ran on changed Dart files.
- Analyzer passes with zero new ignores.
- Relevant tests pass.
- Generation was run only if required and output reviewed.
- Error, concurrency, lifecycle, scanner, navigation, and localization risks were checked.
- No secrets, environment values, or ignored files were exposed.
