# P10/P12 — расширенные результаты и описание карты

2026-09-09 · awaiting_manual_check, baseline 926a5da.

## Два локальных коммита

1. Score statistics/maximum_statistics: typed counts, все полученные ключи,
   без подстановки нулей и пересчёта accuracy. Mod settings: bool/number/string,
   неизвестный сложный тип явно недоступен, не теряет имя. Bounded lazy modal
   вместо растущей Column; summary list остаётся компактным.
2. Optional description.description (HTML) набора → общий безопасный content DTO/domain
   и ContentFrame; тот же collapsible reader для профиля и карты. Нет scraping,
   WebView, дополнительных scopes/запросов на карточку. Raw BBCode — текстовый
   fallback профиля, не обещание собственного полного BBCode parser. Поле bbcode
   набора требует права редактирования и клиентом не запрашивается.

Remote sources возвращают raw payload, repository вызывает DTO/mapping. Нет
новых зависимостей. API version/legacy:false, OAuth, Bloc lifetime и paging не меняем.
Новые подписи во всех семи ARB. API identifiers неизвестных hits/settings сохраняем.
Сторонние .gitignore/.metadata/analysis_options.yaml/pubspec.lock/ios/test не трогаем.

Текущая проверка по уточнению пользователя: только format, analyze lib/packages
и review/diff. APK больше не собираем/не проверяем. Ручная приёмка: все четыре режима, отсутствие/нули в statistics,
DT/DA settings и unknown mod, длинные названия, dismiss/Back/map action; description
empty/malformed/HTML/raw, картинки/ссылки/сворачивание/refresh. Revert по коммиту.

Контракты: [Score/Mod](https://osu.ppy.sh/docs/index.html#score),
[hit results](https://github.com/ppy/osu/wiki/Scoring),
[описание набора](https://github.com/ppy/osu-web/blob/master/app/Transformers/BeatmapsetDescriptionTransformer.php).

Score-срез реализован в 3245cc4: statistics и maximum_statistics — nullable counts,
не 300/100/50 для всех режимов. API names показаны явно с пояснением; strings,
bool и numbers настроек не превращаются в JSON в domain. Пределы: 128 типов
на словарь, 64 mods, 64 settings/mod, строки до 2048 символов. Unknown complex
settings сохраняют имя и отображают «Недоступно», без второго parser.
Analyze lib/packages чистый. Debug catalog/main были собраны до нового запрета
на сборки; дальше не повторяем. Ручная проверка ожидается.

Content-срез реализован: ContentPageDto явно различает profile.page.html/raw
и beatmapset.description.description; общий ContentPageSection раскрывает
ContentFrame.sliver только по действию пользователя. Пустой блок скрывается,
невалидный или превышающий лимиты сохраняет ссылку на оригинал и не скрывает
остальные данные. Внешние HTTPS-изображения загружаются по принятой политике
reader с предупреждением об IP, без WebView и дополнительных API-запросов.
Удалены ProfilePageDto/ProfileAbout и отдельный profile_about.dart, старые
неиспользуемые ARB-подписи; общие подписи больше не привязаны к профилю.
Следующий продуктовый срез — рейтинги, затем новости по активному контракту.

Финальный gate content-среза: gen-l10n, dart format изменённых файлов,
dart analyze lib packages — No issues found, git diff --check — чисто.
После уточнения пользователя APK/каталог не собирались и не запускались;
автотесты не выполнялись. Поведение на устройстве пока не подтверждено.
