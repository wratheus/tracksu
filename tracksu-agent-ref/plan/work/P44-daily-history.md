# P44 — История карты дня, список и итоговый рейтинг

2026-10-07 · awaiting_manual_check. Завершение незакоммиченной работы Claude по поручению пользователя.

## Scope и исходная точка

История карты дня, список и итоговый рейтинг. Сохраняем существующие feature-local Bloc/data/UI и guest-доступ.
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

- История: 30 → 60 → … → 250 последних комнат, без cursor; ограничение видно в конце.
- Исправлены потеря done после ошибки refresh и Retry, ошибочно выполнявший load-more.
- Архив доступен даже при пустой/ошибочной сегодняшней карте.

| Риск | Проверка | Результат |
| --- | --- | --- |
| Потеря конца списка при refresh error | history_test: сначала RED, после исправления GREEN | PASS |
| Retry пропускает/меняет порцию | запросы 30,60,60,60,60 | PASS |
| Дубли и не-daily комнаты | repository_test | PASS |
| Реальный ответ и старые дни | guest API вернул 60 комнат | PASS |
| История → день → рейтинг → карта | GUI, 6 октября 2026, What's a Future Funk?, 4999 участников | PASS |
| Догрузка/refresh жестами в GUI | Mac заблокирован во время проверки | не завершено |

Контракт: [RoomsController](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/Multiplayer/RoomsController.php),
[Room::search](https://github.com/ppy/osu-web/blob/master/app/Models/Multiplayer/Room.php).
Недокументированные daily-category/leaderboard остаются риском изменения API.

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

Коммит реализации: `a63459d`; общие локализации: `837974f`.

## Обложки в списке (2026-10-09)

Строка дня — дата слева, справа поверх приглушённой обложки дня, которая
проявляется справа налево (маска-градиент); без картинок — как раньше.
