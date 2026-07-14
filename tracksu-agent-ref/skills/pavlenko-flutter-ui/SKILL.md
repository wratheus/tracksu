---
name: pavlenko-flutter-ui
description: Build Flutter UI in Aleksandr Pavlenko's preferred project-native style. Use for screens, widgets, forms, lists, dialogs, navigation, localization, loading/error states, hardware keyboard, scanner UI, themes, or lifecycle work. Enforces design-system reuse, spacing without SizedBox, BLoC side-effect separation, safe async context use, and mobile/terminal behavior.
metadata:
  author: OpenCode for Aleksandr Pavlenko
  version: "1.0"
---

# Preferred Flutter UI

## First Principle

Do not create a parallel design system. Inspect the existing package/barrel and shared widgets first, then compose the screen from established text, button, field, list, loader, error, icon, modal, and theme APIs.

Within TSD-style repositories, prefer the public `tsd_ui` API, `UiText`, `Button`, `InkBtn`, `UiTextField`, `PageLoaderWidget`, `ErrorPage`, shared list groups/items, `NavigatorPage`, and `NavigatorModal`.

## Screen Structure

- `XxxMain` owns feature construction and providers.
- `XxxScreen` owns `Scaffold`, state rendering, and UI side effects.
- Extract widgets when they form a coherent reusable/independently readable section, not merely to shorten a file.
- Use `StatelessWidget` by default.
- Use `StatefulWidget` for controllers, focus nodes, timers, subscriptions, observers, or stable callback state.
- Never create controllers, focus nodes, timers, or BLoCs inside `build`.

## Design-System Rules

- Import the package's public barrel rather than internal `src` files.
- Use semantic text presets instead of raw `TextStyle` when available.
- Explicitly use left alignment for list/long-form text if the design-system text defaults to centered.
- Use the established primary button rather than `ElevatedButton`.
- Use established list rows/cards, chips, icon backgrounds, loaders, and error pages.
- Give interactive controls stable, meaningful keys when the component API or tests need them.
- Use built-in loading/disabled states rather than duplicating tap guards and spinners.
- Do not duplicate haptic feedback already implemented by a shared control.

## Theme and Color

- Read colors and typography from the active theme or theme extension.
- Prefer project context extensions such as `context.theme`, `context.themeModeColors`, and `context.mq` when present.
- Use semantic colors for container backgrounds, text, approved/rejected states, and controls.
- Do not hardcode `Colors.white`, near-duplicate grays/blues, or font sizes in ordinary theme-aware UI.
- Preserve light and dark themes.
- Use platform checks only for real platform capabilities or established route/UI policy.

## Spacing and Layout

Hard rule: never use `SizedBox` as spacing between elements.

- Use `spacing` on `Row` and `Column` for sibling gaps.
- Use `Padding` for a single inset.
- `SizedBox` remains valid for genuine size constraints and `SizedBox.shrink()`.
- Follow the existing spacing scale. In TSD-style screens it is generally `5`, `10`, `15`, `20`, and `30`.
- Prefer existing corner radii and gutters rather than introducing almost-identical values.
- Use `Expanded` for bounded remaining space, not guessed heights.
- Use slivers or builder lists for long/dynamic collections.
- Do not wrap a large dynamic list in `SingleChildScrollView`.

Preferred fixed-bottom-action shape:

```dart
Column(
  children: [
    Expanded(child: content),
    SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 15),
      child: action,
    ),
  ],
)
```

If content scrolls under an overlaid bottom action, reserve enough bottom space for the action.

## BLoC Rendering and Side Effects

- `BlocBuilder`/`AnimatedBlocBuilder` renders state only.
- `BlocListener` performs navigation, modal presentation, focus changes, toasts, and other one-shot effects.
- Use `BlocConsumer` only when one subtree genuinely needs both.
- Render sealed states with an exhaustive switch.
- Always provide deliberate loading, loaded, empty, error, and completion UI where states exist.
- Prefer the project's animated builder for full-screen state transitions.
- Use a narrow builder with `buildWhen` for a small title/count/field update instead of rebuilding the screen.
- Never navigate or show a modal from a builder.

## Forms

- Construct `TextEditingController`, `FocusNode`, debounce objects, and timers once in `State`.
- Initialize input values in `initState`.
- Dispose every owned lifecycle object.
- Trim user input before domain submission unless whitespace is meaningful.
- Debounce search input; do not call an API directly on every `onChanged`.
- Set `keyboardType`, `textInputAction`, and `maxLines` deliberately.
- Use `done` for submit and `newline` for multiline input.
- Keep forms visible above keyboard and inside safe areas.
- Prefer state-driven business validation through the feature's BLoC/error infrastructure.
- Use the shared text field instead of a raw `TextField` when its behavior is sufficient.

## Navigation and Modals

- Navigate through the central facade/helper, not duplicated route strings or ad hoc `MaterialPageRoute`.
- Use typed route params.
- Preserve existing iOS/Android transition policy.
- Use the established modal-bottom-sheet API for confirmations and alerts rather than introducing `AlertDialog` styling.
- Return modal results through `Navigator.pop(context, result)`.
- After every navigation/modal `await`, check `context.mounted` before accessing context.
- Before using a retained BLoC after `await`, check `!bloc.isClosed`.

## Localization

- No hardcoded user-facing strings.
- Prefer `context.t.key` in widgets.
- Use global localization access only when context is objectively unavailable and the project supports it.
- Use named placeholders for dynamic phrases rather than concatenating translated fragments.
- Add keys to every supported locale source.
- Run the repository's generation command.
- Never edit generated localization files manually.

## Lifecycle

- Register observers/subscriptions/controllers in `initState` or the appropriate lifecycle hook.
- Cancel/dispose them before `super.dispose()` when consistent with the API.
- Use `didUpdateWidget` when an incoming parameter controls an active resource.
- Check `mounted` after asynchronous work and post-frame callbacks.
- Stop camera/native resources on inactive lifecycle states when required.
- Do not store `BuildContext` in services.
- Access an inherited dependency in `initState` only when the repository guarantees it is stable; otherwise use `didChangeDependencies`.

## Terminals, Keyboard, and Scanners

- Assume both touch devices and Android hardware terminals when the application supports them.
- Mount scanner providers around the whole route, not inside a BLoC builder branch.
- Ensure scanning is disabled when the route is not visible and restored when active.
- In keyboard handlers, act on `KeyDownEvent` to avoid duplicate execution.
- Own and dispose the keyboard `FocusNode`.
- Use existing terminal/device capability APIs instead of raw platform assumptions.
- Hide or disable unsupported platform actions before calling plugin APIs.
- Keep confirmation behavior for replacing an active scanned entity consistent with neighboring features.

## UI Completion Checklist

- Existing components and theme tokens are reused.
- Screen works in light/dark theme and with supported text scaling.
- No `SizedBox` is used as a gap.
- Lists and scroll constraints are sound.
- Builders are pure; listeners own side effects.
- All states have intentional UI.
- Controllers, focus, timers, and subscriptions are disposed.
- Async context use is mounted-safe.
- User-facing text is localized.
- Hardware terminal and platform behavior remain valid.
- Analyzer and relevant widget tests pass.
