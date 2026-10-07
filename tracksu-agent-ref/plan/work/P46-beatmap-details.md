# P46 — Фильтр модов и статистика сложности

2026-10-07 · awaiting_manual_check. Завершение незакоммиченной работы Claude по поручению пользователя.

## Scope и исходная точка

Фильтр модов и статистика сложности. Сохраняем существующие feature-local Bloc/data/UI и guest-доступ.
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

- Фильтр модов: применение/сброс, NM, взаимоисключение EZ/HR, HT/DT/NC,
  NF/SD/PF, HD/FI и выбора количества клавиш; mounted guard после sheet.
- Cache и scope leaderboard учитывают моды; смена сложности сбрасывает фильтр.
- Stats optional: плохие данные не скрывают всю карту; отсутствующие counts
  не заменяются нулями; некорректный passcount > playcount не показывается.

| Риск | Проверка | Результат |
| --- | --- | --- |
| Несовместимые моды/NM/reset | mod_filter_test, реальный sheet | PASS |
| Старый cache для другого фильтра | request_cache_test | PASS |
| Потеря mods при построении URL | request_cache_test, реальный HttpRestClient | PASS |
| Ошибка optional stats / лишние поля taiko, mania | difficulty_stats_test | PASS |
| Реальный NM/HD запрос гостем | 50 NM результатов (43 пустых, 7 CL), HD содержит HD с preference-модами | PASS |
| Статистика сложности в GUI | Reminiscence: CS4/HP5/OD9/AR9.2, combo1644, objects1047, plays9955, pass31.3% | PASS |
| Применение модов и смена сложности в GUI | Mac заблокирован | не завершено |

Семантика фильтра сохраняет поведение osu!: CL/PF/SD/MR сервер считает
preference mods и не исключает из NM, если они не выбраны явно.
[ScoreSearch::addModsFilter](https://github.com/ppy/osu-web/blob/master/app/Libraries/Search/ScoreSearch.php).
Не фильтруем такие строки повторно на клиенте.

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
