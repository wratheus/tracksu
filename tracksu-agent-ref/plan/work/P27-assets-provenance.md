# P27 — происхождение assets и native-очистка

2026-09-22 · аудит выполнен, весь продукт не объявляется готовым по лицензиям.
Baseline `c5502a7`, чистый worktree на старте. Продолжение P01.2.

## Tracked inventory до изменений

| Группа | Файлов / исходных байтов | Consumer / решение |
| --- | --- | --- |
| Флаги | 225 / 583 639 | OsuCountryFlag, парные country/team flags, language picker; оставить |
| Иконки режимов | 4 / 1 002 852 | OsuRulesetIcon, все четыре режима; оставить |
| Exo 2 regular + italic | 2 / 547 032 | TracksuTheme + pubspec; оставить, OFL notice подключён |
| utils | 2 / 151 744 | product catalog и README; оставить |
| countries.json | 1 / 3 845 | AssetRankingCountriesLocalSource; 101 запись, нужен country picker |
| exo2.txt | 1 / 4 382 | registerAssetLicenses → Settings/About/LicensePage |
| Android res | 24 / 1 189 296 | Manifest → mipmap launcher; LaunchTheme → launch_background → mipmap cloud_logo |

Это байты исходников, не размер APK. Игнорируемые служебные файлы не учитывались
и не удалялись. Действующие изображения, шрифты и стили не менялись.

## 225/225 флагов: точный исторический источник

Все локальные PNG имеют одинаковый Git blob SHA-1 с одноимёнными файлами
`ppy/osu-resources` в ревизии `c520a9cc9dc75c10eabb0362758f150d2fcc4c8e`,
каталог `osu.Game.Resources/Textures/Flags/`, включая `__.png`.
Сопоставлены имена и хэши из `git ls-files -s assets/icon_country_flags`
и [закреплённого GitHub tree](https://api.github.com/repos/ppy/osu-resources/git/trees/c520a9cc9dc75c10eabb0362758f150d2fcc4c8e?recursive=1).

[README этой ревизии](https://github.com/ppy/osu-resources/blob/c520a9cc9dc75c10eabb0362758f150d2fcc4c8e/README.md)
указывает CC-BY-NC 4.0; [LICENCE.md](https://github.com/ppy/osu-resources/blob/c520a9cc9dc75c10eabb0362758f150d2fcc4c8e/LICENCE.md)
имеет blob `43fbc03ee6503654f5aa2b222f92238ff181deba`.
Следующий [commit f9b9148](https://github.com/ppy/osu-resources/commit/f9b9148a032c14477f6ad509586ed6284731cd04)
заменил набор на Twemoji в 2022. С нынешними флагами совпал только `__.png`:
современное Twemoji/CC-BY уведомление нельзя приписывать нашим старым файлам.

Добавлен `assets/licenses/osu_legacy_flags.txt`: attribution, revision и license
links, disclaimer; регистрация в LicenseRegistry рядом с Exo 2. Описание раздела
обновлено на семи языках. Notice доступен offline; полный текст CC-лицензии
не копируется, приведены ссылки на него. Bytes изображений не изменены.

До коммерческого распространения нужен отдельный выбор: разрешение на старый
набор либо согласованная замена с подходящими условиями. Аудит не выдаёт
разрешения и не проверяет всю цепочку прав. osu!/ppy branding не покрывается.

## Шрифты и незакрытые источники

В ревизии `89085ca2faabb81a6884129b0cd68c48805e8f6c` отдельные notices
[Torus](https://github.com/ppy/osu-resources/blob/89085ca2faabb81a6884129b0cd68c48805e8f6c/osu.Game.Resources/Fonts/Torus/LICENCE)
и [Venera](https://github.com/ppy/osu-resources/blob/89085ca2faabb81a6884129b0cd68c48805e8f6c/osu.Game.Resources/Fonts/Venera/LICENCE)
требуют коммерческую лицензию для распространения. Автоматически не копировать
их TTF по общей лицензии репозитория. Это не идентификация шрифта на скриншоте.
Оба SHA-256 локальных Exo 2 совпали с P22, OFL notice остаётся отдельным.

Открыто: точное происхождение/разрешения mode PNG, painted_logo, баннера и native
launcher artwork. Старое README ссылалось на osu-resources в целом — этого
недостаточно для каждого файла. Четыре mode PNG имеют 250×250 и по 250 713 bytes;
lossless-оптимизация возможна отдельным срезом, здесь перекодирования нет.
JSON country names не является полным локализованным справочником.

## Адресная очистка

Удалены **8 PNG / 610 464 байта (~0,582 MiB)**:

- `android/app/src/main/res/launcher_icon.png` — вне resource directory.
- `android/app/src/main/res/drawable/cloud_logo.png`.
- `android/app/src/main/res/drawable/launcher_icon.png`.
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`.
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`.
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`.
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`.
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`.

Поиск не нашёл consumers этих имён/типов ресурсов или dynamic getIdentifier.
Manifest использует **mipmap/launcher_icon**, splash — **mipmap/cloud_logo**;
все их density variants сохранены. Одинаковые bytes cloud_logo в разных density
buckets не повод объединять их: это способно изменить логический размер splash.
В launch_background.xml пояснение оформлено XML-комментарием, внешний вид прежний.

Удалённое восстанавливается из `c5502a7` адресным Git restore; история не переписана.
Не обещаем уменьшение APK на эту величину: shrinker мог исключать часть и раньше.

## Проверка и остаток

Scoped formatter, gen-l10n, deterministic pubspec generation, analyze lib/packages,
diff review. Lockfile не менялся. Тесты, APK, приложение и каталог не запускались.
Результат analyze: **No issues found (3.4s)**. `git diff --check` и staged diff
чистые; `xmllint --noout` успешно проверил manifest, оба launch_background и styles.
Diff подтверждает отсутствие изменений в активных Flutter PNG/TTF и lockfile.
Ручная приёмка: LicensePage offline и launcher/splash при следующем запуске
пользователем. Полная лицензионная/branding готовность P01.2 остаётся открытой.
