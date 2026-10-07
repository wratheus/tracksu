# P47 — Рейтинг Kudosu

2026-10-07 · awaiting_manual_check. Завершение незакоммиченной работы Claude по поручению пользователя.

## Scope и исходная точка

Рейтинг Kudosu. Сохраняем существующие feature-local Bloc/data/UI и guest-доступ.
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

- Четвёртая вкладка рейтингов, загрузка при первом открытии; режим и PP/Score скрываются.
- Remote source отвечает за HTTP, repository — decoding/failures, Bloc — refresh/paging.
- Пустой список имеет empty-state; refresh отражается общей полосой загрузки.
- До 20 страниц × 50 пользователей; total и available разделены, profile navigation подключена.

| Риск | Проверка | Результат |
| --- | --- | --- |
| Повтор страницы за пределами 1000 | ranking_test: полная 20-я страница завершает выдачу | PASS |
| Дубли/refresh failure теряют список | ranking_test: 99 уникальных строк сохраняются, retry восстанавливает | PASS |
| Malformed kudosu превращается в ноль | ranking_test | PASS |
| Guest API/форма ответа | первая страница: 50 users, available/total присутствуют | PASS |
| Скрытие фильтров, профиль, scroll в GUI | Mac заблокирован | не завершено |

[RankingController::kudosu](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/RankingController.php).

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

Коммит реализации: `1e570c7`; общие локализации: `837974f`.
