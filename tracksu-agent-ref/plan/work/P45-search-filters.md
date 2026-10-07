# P45 — Все режимы, жанр и язык в поиске карт

2026-10-07 · awaiting_manual_check. Завершение незакоммиченной работы Claude по поручению пользователя.

## Scope и исходная точка

Все режимы, жанр и язык в поиске карт. Сохраняем существующие feature-local Bloc/data/UI и guest-доступ.
Исходники уже присутствовали; локализации, карточки и проверки отсутствовали.
Baseline: analyzer — 72 diagnostics (отсутствующие l10n и constructor hints);
iOS build/GUI ещё не проверены. Новые социальные функции, OAuth и iPad вне scope.

## План и критерии

1. Проверить API-контракт, состояния загрузки/ошибки/retry и владение ресурсами.
2. Завершить семь ARB-каталогов и генерацию; исправить подтверждённые дефекты.
3. Целевые regression tests, format/analyze, iOS simulator build и GUI.
4. Обновить README/CHANGELOG/ROADMAP и сделать тематический локальный коммит.

Откат: revert тематического коммита; схемы storage не меняются.
Пользовательская визуальная приёмка отделена от технических проверок.

## Проверки

- «Все» очищает ruleset; genre/language входят в query identity и сохраняются в paging.
- Полный набор жанров/языков переведён; отсутствующий фильтр не передаётся в URL.

| Риск | Проверка | Результат |
| --- | --- | --- |
| Any превращается в osu или теряются g/l | filter_request_test, реальный HttpRestClient + mock HTTP | PASS |
| Новый запрос продолжает старый cursor | beatmap_search_test | PASS |
| Guest API не принимает фильтры | g=10,l=5: 50 наборов, total=8505 | PASS |
| Pickers, клавиатура, экран выдачи | GUI заблокирован lock screen Mac | не завершено |

## Общая техническая проверка 2026-10-07

- `fvm flutter gen-l10n`: PASS; `l10n_untranslated.json` = `{}`.
- `fvm flutter analyze --no-pub`: PASS (0 diagnostics).
- `fvm flutter test --no-pub`: 63 PASS; затем отдельно 2 теста difficulty stats.
- Xcode 27 → Runner → Tracksu iPhone 17 (iOS 27): build/run PASS.
  Первый старт после boot задержался на attach отладчика; приложение затем
  открылось и guest-сеть работает. Подтверждён текущий UI с новой статистикой.
- UI-приёмка пользователем открыта. Часть GUI-проверок прервана блокировкой Mac;
  автоматическая разблокировка не сработала, запрошена ручная разблокировка.
- Skills: pavlenko-flutter-feature, pavlenko-dart-style,
  pavlenko-flutter-ui, pavlenko-flutter-quality.

Коммит реализации: `e485455`; общие локализации: `837974f`.
