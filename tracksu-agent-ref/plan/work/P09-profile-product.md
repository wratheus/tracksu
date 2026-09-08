# P09 — профиль как отдельная продуктовая страница

2026-09-08 · baseline 70b410b, дерево чистое. Статус — в ROADMAP.

Цель: из точного поиска/рейтинга открыть читаемый профиль с настоящей обложкой,
статистикой и раздельными обзором, результатами и картами. Тип: data + UX.

## Контракт среза и один плановый коммит

- Source/endpoint/scopes без изменений; repository преобразует DTO в domain.
  Добавляем cover.url, level, grade_counts, дополнительные счётчики и rank_history
  по официальному UserExtended/UserStatistics, без legacy cover_url.
- Метрика = отдельная подпись и локализованное значение. null — отсутствие,
  не #0; play_time nullable. История — последовательность наблюдений, без
  выдуманных дат; пропуски не соединяются линией и не становятся rank 0.
- Обзор / результаты / карты: независимые lazy scroll sections, сохранение
  загруженных секций при переключении; форма поиска остаётся на SearchHome.
- При смене ruleset шапка и прошлые данные остаются с явным статусом; новые
  результаты принимаются latest-wins, ошибка возвращает прежний режим.
- Состояния и async принадлежат ProfileBloc и локальным Bloc секций;
  controllers вкладок принадлежат profile widgets, UI kit только рисует.

Не входят: partial-name/map search endpoints, переделка карточек scores/maps,
rankings/news, новые auth/nav/storage/SDK, смена палитры, analytics, новые assets.
Это следующий срез после P07.2, не утверждение готовности всех экранов.

Проверки: format/analyze, gen-l10n семь языков, main/catalog debug APK,
diff/lifecycle review. Автотесты T01 не создаются и не запускаются.
Ручная проверка: ID/@numeric name, четыре режима и быстрая смена, refresh/error,
null statistics/play_time/rank, cover fallback, вкладки/scroll/Back, большие
числа, CJK/крупный шрифт, график с пропусками. На устройство не устанавливаем.

Возврат: адресный revert коммита; сохранённые данные/ключи не мигрируются.
README/CHANGELOG, API reference и активная очередь обновляются в том же коммите.

Источник: [osu! API](https://osu.ppy.sh/docs/index.html#userextended), проверен
2026-09-08. У rank_history нет дат отдельных точек; календарные даты не обещаем.

## Результат среза

Реализован весь контракт выше. Визуальный ориентир — Stitch Player Profile,
а композиции — существующие OsuPlayerCard/UiSurface/UiMetric/UiChart; новые
ассеты, Follow/PRO и смена глобального стиля не добавлялись. Chart получил
breakBefore и точки для одиночных наблюдений; пример добавлен в UI catalog.
Неиспользуемый ProfileCleared удалён; общий JsonMapReader получил optionalString.
Source по-прежнему raw, DTO создаёт repository. Дублирования JSON helpers нет.

Итог проверок 2026-09-08:

- `fvm flutter gen-l10n`: семь языков, missing-translations report `{}`.
- `fvm dart format`: затронутые Dart-файлы отформатированы.
- `fvm flutter analyze --no-pub`: No issues found.
- `fvm flutter build apk --debug --no-pub --target lib/ui_catalog.dart`: успешно.
- `fvm flutter build apk --debug --no-pub`: успешно; итоговый APK — приложение.
- `git diff --check`: без ошибок. JDK25 native-access warning неблокирующий.
- Автотесты не создавались/не запускались, APK не устанавливался; device/UX
  и live API ответы этим прогоном не подтверждены. Публичного push нет.

Проверить вручную: пролистать результаты/карты, переключить вкладки и вернуться;
при смене ruleset результаты начинают новый список сверху, карты сохраняются.
Быстро сменить несколько режимов, прервать сеть, повторить неудавшийся режим;
данные и selector должны соответствовать друг другу после окончания запроса.
Проверить профиль без statistics/cover/rank, график, крупные числа/шрифт и CJK.

Следом P10 scores: компактная карточка, media и отдельные подробности результата;
затем карты P10/P12. Их внутренний UI здесь не переделывался. Поиск пока exact
lookup, partial-name выдача и поиск карт требуют отдельного API-контракта.
