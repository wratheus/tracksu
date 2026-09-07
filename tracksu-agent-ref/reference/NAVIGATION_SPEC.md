# P07.2 — мобильная навигация и stateful shell

2026-09-07 · реализовано, awaiting_manual_check. Пользователь подтвердил оба
решения: go_router/три ветки/панель на деталях/OAuth overlay и Back к Поиску.
Это текущий контракт; не повторять выбор router на следующем шаге.

## ADR — принято и реализовано

go_router 18.0.1 совместим с закреплёнными Flutter 3.47.2 / Dart 3.13.2.
StatefulShellRoute.indexedStack владеет тремя лениво создаваемыми Navigator:

| Ветка | Корень | Детали |
| --- | --- | --- |
| Поиск | /search, SearchHome: имя/ID, ruleset, необязательный account menu | Профиль → набор/сложность |
| Рейтинги | /rankings, существующие фильтры и paging | Профиль → карта; Spotlights → карта |
| Новости | /news, существующая лента | Статья |

Общие detail routes объявляются в каждой ветке, typed TracksuAppRouter остаётся
единственной точкой знания путей. Фичи не получают router в repository/Bloc.
ProfileParams поддерживает ID и username; параметры ID/name/ruleset сериализуются,
неположительные ID/неизвестные modes отвергаются. Новых публичных App Links
для профилей/карт этот срез не регистрирует.

Root Navigator — shell и OAuth. Тёплый вход push поверх существующего контекста,
холодный callback поверх /search. Успех снимает только auth route. Ошибки входа
остаются на auth с retry/Back, не изображают успешную сессию.
Android flutter_deeplinking_enabled=false: callback принимает только app_links,
а не параллельно GoRouter. Полный URI передаётся в auth только в памяти,
без code/state в route paths, extras, restoration, логах или аналитике.
Регистрация callback, parser/state checks и secure transaction store не менялись.

UiNavigationBar в tracksu_ui владеет Material appearance/semantics, но не router.
StatefulShellRoute владеет lifetime/стеками. Стандартные MaterialPage transitions
адаптируются к платформе; своих свайпов, curved_navigation_bar или глобального
fade вместо Cupertino gesture нет. iOS host по-прежнему отложен до P04.

## Back, переключение и состояния

1. Верхнее меню/sheet/диалог закрывается первым. Клавиатура обрабатывается
   платформенно, без дополнительного pop страницы.
2. GoRouter пробует maybePop активного Navigator ветки, затем root.
   Detail pop возвращает предыдущий экран в исходной ветке.
3. PopScope расположен только на root-page shell: на корне Рейтингов/Новостей
   Android Back выбирает сохранённую ветку Поиска. Он не зарегистрирован
   в route деталей и не запрещает их native swipe/pop.
4. Только Back в самом корне Поиска может штатно выйти в ОС. Не вызываем
   exit/SystemNavigator.pop и не делаем второй pop после успешного.
5. На корне iOS нет искусственного swipe-to-exit или swipe между вкладками.

Переключение вкладки сохраняет её стек и widget/Bloc/controller state.
Повторный tap текущей вкладки ничего не сбрасывает. Фокус при переходе в другую
ветку снимается. Нижняя панель остаётся на профиле/карте/статье, OAuth скрывает её.
Нет eager preload всех веток. Уже начатый короткий запрос может завершиться
в сохранённой ветке; fetch не запускается заново лишь от tab tap.
Аккаунт обновляется через status-only stream: cold OAuth, logout, invalidation.
Обычное обновление access token не перестраивает экран по status stream.

**Ограничения:** переход Back между корнями вкладок — смена ветки, не
интерактивная predictive-анимация Поиска. Predictive Back деталей и завершённый/
отменённый Cupertino swipe требуют устройства. Будущие audio/timers/subscriptions
должны учитывать visibility; IndexedStack не является универсальной pause policy.
При будущих приватных фичах logout/account switch обязаны очищать их state и
блокировать stale responses; публичные просмотренные профили не удаляем заодно.

## Восстановление

MaterialApp.router, GoRouter, shell page и каждая branch имеют restoration IDs.
В scope входят активная ветка и сериализуемые маршруты/публичные IDs/username/mode.
Bloc/API данные после пересоздания загружаются заново. Форма поиска, изменённые
локальные фильтры, paging и scroll state гарантируются кодом lifetime только
в живом процессе; полное сохранение после process death/force-stop не обещается.
API-кеш не сериализуется. OS-managed route restoration учтено в P01.3 data inventory.
OAuth credentials/code/state не являются restoration state.
После возвращения iOS host отдельно установить FlutterDeepLinkingEnabled=false
при сохранении app_links ownership, настроить capabilities и проверить callback.

## Проверки checkpoint

- gen-l10n: три новых сообщения во всех семи ARB, untranslated report пуст.
- Format/analyze lib и трёх packages: без замечаний.
- Debug APK каталога и main: собраны; после manifest change main пересобран
  (10,8 с), merged manifest содержит отключение Flutter deep-link handler.
- git diff --check чист; 225 flags сохранены в APK, untranslated report {}.
- Автотесты не писались/не запускались. Приложение на устройство не устанавливалось.
- Успешная сборка не заменяет следующие ручные проверки.

## Ручной checklist

- Поиск: username/ID/@числовое имя, пустой ввод, Enter/кнопка, быстрый двойной tap.
- Поиск → профиль → карта → Новости → Поиск: тот же route, состояние и scroll.
- Рейтинг со страной/mania variant → профиль → карта → Back два раза:
  тот же рейтинг, фильтры, страница и позиция.
- Новости → статья → Рейтинги → Новости: та же статья; Back → прежняя лента.
- Back на корне вторичной вкладки → сохранённый Поиск, в том числе его детали;
  следующий Back снимает эти детали, выход возможен только с Search root.
- Retap вкладки, popup/sheet/клавиатура, крупный шрифт и длинные локализации.
- OAuth success/cancel/error, уже активная browser session, cold callback:
  нет сброса вкладок, второго shell/browser или лишнего route; menu отражает вход.
- Local logout/refresh failure, смена языка/системной темы и background/resume.
- Android button/gesture Back, отменённый predictive gesture; process recreation
  в заявленном route-only scope. iOS swipe/cancel и модалки — после P04.

Следующий срез: поиск/профиль по [поэкранному плану](../plan/work/P07-product-integration.md),
а не новая переделка foundation. Финальная графика/все API projections не входят
в этот checkpoint.

## Официальные основания

Проверены 2026-09-07, дополнительно прочитаны установленный go_router delegate/
builder и пример stateful_shell_route. Документы описывают механизм, не выбирают UX.

- [go_router](https://pub.dev/packages/go_router)
- [StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html)
- [State restoration](https://pub.dev/documentation/go_router/latest/topics/State%20restoration-topic.html)
- [Flutter: plugin-based deep linking](https://docs.flutter.dev/ui/navigation/deep-linking)
- [Flutter: platform adaptations](https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations)
- [Flutter: predictive back](https://docs.flutter.dev/platform-integration/android/predictive-back)
