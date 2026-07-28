# Зачем Tracksu использовал GitHub Pages и что можно заменить

2026-09-04 · предварительное исследование для P05. Legacy Pages source позже
удалён из repository по явному решению пользователя; приложение, OAuth
registration и внешний hosting этим документом не менялись.

## Подтверждено исходниками

1. [authorization_page.dart:19](/Users/aleksandrpavlenko/Projects/tracksu/lib/src/pages/authorization_page.dart:19)
   открывает официальный `/oauth/authorize` в WebView и передаёт
   `redirect_uri=https://wratheus.github.io/tracksu`.
2. После загрузки страницы WebView вызывает `currentUrlCheck`. В
   [обработчике:45](/Users/aleksandrpavlenko/Projects/tracksu/lib/src/pages/authorization_page.dart:45)
   приложение читает текущий URL, ищет возврат на Pages, извлекает `code`
   регулярным выражением и вызывает `getTokenAsAuthorize`.
3. [requests.dart:24](/Users/aleksandrpavlenko/Projects/tracksu/lib/src/requests/requests.dart:24)
   выполняет POST на osu! `/oauth/token` прямо из приложения; тот же Pages URL
   передаётся как redirect_uri. Обмен кода на токены не выполняется сайтом.
4. Удалённый в workspace migration корневой `index.html`
   содержит только HTML-заглушку: заголовок loading и фон. Нет JS, формы входа,
   обмена токенов или сервера. Это не Flutter Web app: при первичном осмотре
   отдельный Flutter Web template в этом checkout отсутствовал.

Следовательно, роль Pages в этом checkout — адрес назначения OAuth-редиректа
и визуальная заглушка внутри WebView. Это не BFF, API proxy или собственная
авторизация. Выбор Pages как бесплатного доступного HTTPS-хостинга выглядит
вероятным мотивом, но историческое намерение автора исходники не доказывают.

```text
WebView → osu! login/consent → Pages URL с ?code=...
                               ↓ приложение читает URL
                            osu! /oauth/token → локальная сессия
```

Настройки Pages в GitHub и зарегистрированный callback в osu! аккаунте не
проверялись. Прямая попытка чтения публичного URL не дала пригодного ответа;
это не подтверждает ни 404, ни работающий сайт. Текущая доступность/причина
возможной поломки остаётся отдельной проверкой P05. Полный OAuth не запускался.

## Почему нельзя просто поменять адрес

- Redirect задан без завершающего slash, а success-handler ждёт `/tracksu/?code=`.
  Поведение зависит от формы URL/редиректов; это хрупкость кода, не установленная
  причина текущего сбоя. Регулярное выражение `code=(.*)` захватит и следующие
  query parameters. Новый обработчик должен разбирать Uri и проверять
  scheme/host/path, одиночный code/error и ожидаемый state.
- `state` в текущем authorize URL отсутствует; code извлекается регулярным
  выражением. Нет явной защиты от повторной обработки одного callback. В P05
  удалены логи access/refresh tokens, но новый callback всё равно обязан
  корректно разбирать URI и валидировать state.
- Authorize использует захардкоженный client ID, token exchange — ID из локальной
  конфигурации; совпадение не проверено. Новый flow должен брать одну конфигурацию.
- README утверждает, что Callback URL не нужен. По документации osu! он нужен
  для Authorization Code Grant; пропустить его можно при использовании только
  Client Credentials Grant. Исправить инструкцию на P02.1/P05, не объявлять
  guest-вход эквивалентом пользовательской сессии.
  [osu! OAuth](https://osu.ppy.sh/docs/index.html#authentication).

## Что можем сделать своим

| Часть | Решение |
| --- | --- |
| Экран входа приложения | Да: свой UI kit, локализация, Continue with osu!, cancel/error/retry и восстановление сессии |
| Ввод osu!-пароля и разрешения | Оставляем на osu!: официальная OAuth-страница в системной auth session, без встроенного WebView и без собственной формы для чужого пароля |
| Возврат в приложение | Да: собственный зарегистрированный callback и native handler; выбрать подтверждённый вариант на P05 |
| Страница callback/fallback | Да, если нужен HTTPS-вариант: минимальная собственная страница на контролируемом домене, без обработки client secret или токенов |
| BFF / серверный token exchange | Не входит в текущую программу; статическая страница не является его заменой |

Native OAuth через внешний user-agent — профильный рекомендуемый подход.
[RFC 8252](https://www.rfc-editor.org/rfc/rfc8252).

На P05 сравнить два варианта, прежде чем выбрать реализацию:

1. **Custom URI scheme / callback системной auth session.** Если osu! принимает
   выбранный redirect и используемый Flutter/native flow его поддерживает,
   отдельная веб-страница для нормального возврата не нужна. Проверить registration,
   Android/iOS cold/warm start, отмену, повторный callback и защиту кода. Наличие
   в стандартном OAuth такого варианта не доказывает поддержку провайдером;
   поддержку PKCE также проверить отдельно, не предполагать.
2. **HTTPS callback на контролируемом домене.** Проверить App Links / Universal
   Links и конкретную системную auth session. Потребуются настройка приложения,
   association-файлы домена и fallback при неустановленном приложении. Один HTML
   файл автоматически такую связь не создаёт.
   [Android App Links](https://developer.android.com/training/app-links/verify-applinks),
   [Apple associated domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains).

Минимальный собственный HTTPS-сайт можно разместить на статическом хостинге;
это отдельное решение о домене/доставке, не backend-разработка. Временно выбран
GitHub Pages в отдельном repository `wratheus/wratheus.github.io`, а не
web-часть Flutter repository.
[Что предоставляет GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages).

## Выбранный временный HTTPS callback

Опубликованный callback: `https://wratheus.github.io/oauth/osu/callback/`.
Страница не читает параметры URL, не выполняет token exchange и не содержит
секретов. Android manifest принимает только этот host/path как App Link. Перед
реальной проверкой входа нужно опубликовать `.well-known/assetlinks.json` с
SHA-256 fingerprint нового release certificate; до появления подписи шаблон
association-файла намеренно не публикуется. OAuth registration пока не
переключалась.

## P05 auth spike

Legacy `LoginScreen` больше не открывает OAuth в WebView. Он формирует URL
официальной osu! страницы с криптографически случайным `state`, открывает его
во внешнем браузере и получает HTTPS callback через `app_links`, переданный
через `DepsContainer`. Parser принимает только выбранный callback host/path,
одиночные `code`/`error` и совпавший state; code, URI и tokens не логируются.
Прежний token exchange — временный legacy bridge до P08, где он перейдёт в
AuthRepository/TokenStore.

При cold start state пока отсутствует в памяти и callback отклоняется
намеренно. Persistent pending authorization transaction, восстановление
session и полный ручной сценарий cold/warm start относятся к P08. До него
проверяем только запуск внешнего браузера и безопасное отклонение неверного
callback; не объявляем end-to-end login готовым.

Для callback-страницы: без Firebase Analytics, сторонних скриптов и внешних
ресурсов, без вывода code/token, без произвольного redirect target. Проверить
referrer/logging/cache policy хостинга и перехода; секрет не помещать в JS.
Сайт не делает mobile client secret защищённым — принятый до BFF риск сохраняется.

## Что именно осталось сделать на P05

- Проверить зарегистрированное OAuth-приложение, владельца и redirect/scopes;
  Pages deployment/source и актуальный публичный URL — без чтения/публикации секретов.
- Принять ADR: собственный entry UI, способ callback, нужен ли сайт/домен,
  поддержка PKCE, residual risks, контракт session и handling ошибок.
- Для выбранной части заранее составить небольшую цепочку коммитов:
  callback contract/handler → wiring проверенного native/browser flow →
  переключение после доступных проверок → отдельное удаление legacy после
  ручного подтверждения. Где требуется token/session implementation, явно
  сослаться на P08; не начинать весь auth rewrite внутри исследования P05.
- Проверить будущий flow вручную пользователем: login/cancel, invalid state,
  warm/cold start, повторный возврат, offline/token failure. Автотесты не добавлять.
- Legacy source уже удалён из repository по явному решению пользователя. P05
  отдельно выясняет потребителей, включая старые установки, и определяет момент
  отключения/ротации OAuth registration и внешнего Pages deployment. Работающий
  новый экран не означает, что старый endpoint больше никому не нужен.

Исследование не завершает P05 и не выбирает первый этап реализации. До нового
поручения не меняем OAuth registration, hosting/DNS, приложение, подпись и секреты.
