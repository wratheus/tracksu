# P22 — О приложении и доступные лицензии

2026-09-10 · awaiting_manual_check · baseline `20a3ad9`, worktree чистый.

## Scope

Страница из настроек: описание неофициального клиента, реальные version/build
и package ID через уже разрешённый транзитивно package_info_plus 10.2.1 (становится
прямой зависимостью той же версии), ссылки на проект/osu!, offline LicensePage.
Две страницы принадлежат текущей ветке shell, с существующим Back/переходами.
Main владеет future platform metadata, UI показывает loading/error/retry,
публичные ссылки запускаются только по нажатию, с обработкой ошибок.

Добавить notice Exo 2 в assets и LicenseRegistry, не менять font binaries и тему.
В name-таблицах обоих локальных TTF: Version 2.000, Natanael Gama,
Copyright 2013 The Exo 2 Project Authors (https://github.com/NDISCOVER/Exo-2.0),
SIL Open Font License 1.1. Текст notice берём из официального Google Fonts до
обновления 2.010: commit e1b807a2579196fa4fb97ee27ea924f67aa78761/ofl/exo2/OFL.txt.
Хэши локальных бинарников не совпадают ни с текущими, ни с проверенными
историческими Google Fonts: точную исходную сборку не объявляем установленной.
Flags/modes/branding и точный osu!-шрифт остаются отдельным provenance-аудитом.

Не публикуем и не изображаем готовыми privacy/terms, не собираем аналитику,
не открываем сторонние страницы автоматически. P01.3 остаётся release gate.

## Проверка и откат

Offline pub get, gen-l10n (семь языков), scoped format, analyze lib/packages,
diff review. Без тестов/APK. Ручная проверка: settings→about→licenses→Back,
открытие Exo 2 без сети, версия установленной сборки, отказ platform metadata,
длинные локали/светлая тема. Откат — revert коммита, без удаления данных.

Источники:
- https://pub.dev/packages/package_info_plus
- https://github.com/google/fonts/blob/e1b807a2579196fa4fb97ee27ea924f67aa78761/ofl/exo2/OFL.txt

## Выполнено

AboutMain/data/domain/widgets, settings entry и два branch routes реализованы.
Metadata future создаётся в main один раз, с 5-секундным timeout/retry;
предыдущий/фиктивный version при ошибке не показывается. Двойные переходы
заблокированы, async UI обращения проверяют mounted. SDK licenses — стандартный
Flutter LicensePage в общей теме; Exo 2 добавлен через LicenseRegistry в main.

- `pub get --offline`: одна смена transitive → direct, версии не изменились.
- gen-l10n: десять новых ключей во всех семи ARB, untranslated `{}`.
- Scoped format, analyze lib/packages и diff review выполнены.
- Тесты/APK/визуальный запуск не выполнялись. Чеклист телефона открыт.

Следующий legal-текст заблокирован не кодом, а недостающим выбором оператора,
контакта и рынков; эти данные нельзя выводить из git author/email.
