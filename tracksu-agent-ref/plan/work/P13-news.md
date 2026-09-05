# P13 — новости

2026-09-06 · awaiting_manual_check. Исходная точка 28035ee: modern analyze/debug APK
проходят, устройство не проверено. Цель — guest список новостей с cursor paging,
чтение внутри приложения и открытие оригинала/ссылок в браузере.

Main → raw source → repository/DTO → Bloc → sliver widgets. List/detail routes
имеют независимые repository/Bloc, запросы отменяются при закрытии. Refresh
сохраняет content, append — загруженные строки; повторные операции игнорируются
во время запроса. Серверный cursor_string непрозрачен, не вычисляется из IDs.

GET /news?limit=12[&cursor_string=...] → news_posts, cursor_string;
GET /news/{id}?key=id → NewsPost с content. Источник — официальные
[NewsController](https://github.com/ppy/osu-web/blob/master/app/Http/Controllers/NewsController.php)
и [NewsPostTransformer](https://github.com/ppy/osu-web/blob/master/app/Transformers/NewsPostTransformer.php),
сверены 2026-09-06. edit_url не является ссылкой для чтения.

HTML — ограниченный reader: allowlist текстовых тегов, без CSS/скриптов/forms/
iframe/embedded media. Ссылки только HTTPS без credentials, относительные
разрешаются относительно официальной статьи. Изображения и сложное оформление
пока доступны через оригинал, не подгружаются автоматически. Заголовки/даты/
кнопки локализованы; содержимое статьи не переводим автоматически. Переиспользуем
существующий HTML renderer, html объявляем прямой зависимостью для sanitizer.

Вне scope: themes/UI kit, поиск по годам, комментарии, media/audio, offline DB,
публикация. Legacy удаляем только после проверки consumers, не весь граф заодно.
Проверка: gen-l10n/format/analyze/debug APK и ручная приёмка, без автотестов.
Откат — scoped commit, storage и внешние настройки не изменяются.

## Реализовано и ограничения

- Кнопка в shell, раздельные list/article routes и params по положительному ID.
  Закрытие статьи не сбрасывает список и scroll; повторный tap строки защищён.
- Busy guard общий для событий каждого Bloc; refresh/paging не пересекаются.
  ID строк дедуплицируются, повторяющийся или циклический cursor — invalidResponse.
  Ошибка refresh сохраняет content и блокирует append до успешного refresh.
- DTO используют JsonMapReader; author/date/title/slug обязательны, preview
  обязателен в списке, content — в статье. Пустой preview/content допустим.
  Статья проверяет совпадение ID ответа. Ошибки не подменяются пустым успехом.
- HTML разбирается один раз в repository, заново собирается только из allowlist.
  Атрибуты полностью отброшены, кроме проверенного href. img превращается в alt,
  активные поддеревья удалены. Предел 2 млн символов/100 уровней вложенности:
  превышение — invalidResponse, не падение UI. Сложные таблицы/оформление и медиа
  доступны в оригинале; это текстовый reader, не копия официального сайта.
- Ссылки повторно проверяются перед external launch; ошибки видны в Snackbar,
  fallback launcher HTML-пакета отключён обработанным callback. Разрешённые
  HTTPS-ссылки могут вести на сторонние сайты; это проверка схемы, не гарантия
  безопасности содержимого сайтов. Fragment-ссылки открываются в оригинале.
- `html` 0.15.1 из существующего lock стал прямой зависимостью, версии пакетов
  не обновлялись. Flutter HTML renderer уже существовал в проекте.
- Public allowlist дополнен только GET /news и /news/{positive ID} на osu.ppy.sh.
  Auth, token lifecycle и API response version не изменены.

Legacy usages: LastNewsPage ещё включён в home_page/home_page_desktop, NewsCubit
и NewsWidget используются только старым экраном; getNews находится в общем
requests.dart. Их удаление относится к P16 вместе с остатком legacy Home/drawer,
а не к удалению одного файла с оставшимися imports. Новый shell не использует их.

## Ручная приёмка

1. Открыть новости гостем, дождаться ленты, догрузить несколько страниц.
2. Открыть статью, проверить текст/списки/таблицу, вернуться к прежнему scroll.
3. «Открыть оригинал» должен вести на osu! /home/news, не GitHub edit_url.
4. Проверить относительную/внешнюю ссылку и возврат из браузера; картинки/видео
   внутри reader не загружаются, предупреждение об этом видно сверху.
5. Offline initial load → retry; offline refresh/append сохраняет данные;
   быстро повторять кнопки, выйти во время загрузки, дважды нажать статью.
6. en/ru, длинные заголовки, крупный системный шрифт и узкий телефон.

Автотесты не писали/не запускали, live API и устройство не проверены. Применены
skills feature/dart-style/UI/quality: локальный DI, raw source/repository parsing,
sliver rendering, scoped state, lifecycle и format/analyze/build без tests.

Технические проверки 2026-09-06: offline pub get изменил только статус html
в lock (transitive → direct), gen-l10n, scoped format; analyze news/rankings/
profile/beatmap/_shared/_core/guest/auth/session и обоих workspace packages —
No issues found. Финальный analyze news/_core/guest также чистый; debug APK
(--debug --no-pub) собран. git diff --check чистый. Прежнее предупреждение
Gradle native access на JDK 25 не блокирует сборку.
