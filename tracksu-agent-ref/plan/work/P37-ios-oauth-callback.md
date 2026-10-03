# P37 — iOS: возврат в приложение после входа в osu!

2026-10-03 · диагностика готова; нужен выбор пользователя.

## Симптом

Simulator Tracksu iPhone 17: osu! → «Авторизовать» → Safari открывает
`https://wratheus.github.io/oauth/osu/callback/?code=…&state=…` и
показывает заглушку «Return to Tracksu». Приложение не получает callback;
при ручном возврате экран входа показывает «Авторизация не была завершена».

## Причина (подтверждена конфигурацией, не догадка)

Callback — HTTPS-ссылка (Universal Link на iOS / App Link на Android).
На Android всё настроено: intent-filter `autoVerify` и
`https://wratheus.github.io/.well-known/assetlinks.json` (есть, с
отпечатком сертификата). На iOS не настроено ничего из трёх обязательных
частей:

1. **Нет entitlement Associated Domains** (`applinks:wratheus.github.io`):
   в `ios/` нет `.entitlements`.
2. **Нет `DEVELOPMENT_TEAM`** в `Runner.xcodeproj`: без команды Apple
   приложение не может заявить домен. Associated Domains доступны только
   платной команде Apple Developer; бесплатная Personal Team их не даёт.
3. **Нет файла `apple-app-site-association`** на домене:
   `https://wratheus.github.io/.well-known/apple-app-site-association` → 404.

Поэтому iOS открывает ссылку как обычную страницу. Это ожидаемый пробел
P04 («OAuth callback/capabilities на iOS — отдельно»), не регрессия кода.

## Варианты

### A. Universal Links (рекомендуется для выпуска)

Тот же callback, что и на Android, без изменений в osu!-приложении.
Нужно: платная Apple Developer команда (Team ID); в репозитории
`wratheus.github.io` файл `.well-known/apple-app-site-association`:

```json
{"applinks":{"details":[{"appIDs":["<TEAMID>.io.github.wratheus.tracksu"],
  "components":[{"/":"/oauth/osu/callback/*"}]}]}}
```

(отдаётся как `application/json`, без расширения; GitHub Pages с
`.nojekyll`, чтобы `.well-known` публиковался); в Xcode — команда и
capability Associated Domains `applinks:wratheus.github.io`;
`FlutterDeepLinkingEnabled=false` (ссылки уже обрабатывает app_links).
Проверка на симуляторе: `xcrun simctl openurl booted <callback>` и
реальный вход.

### B. Пересылка со страницы callback в свою схему (только без платной команды)

Страница callback перенаправляет на `tracksu://oauth/osu/callback?…`,
iOS регистрирует схему в `CFBundleURLTypes`. Работает без Apple
Developer, но: код авторизации проходит через custom scheme (его может
перехватить другое приложение с той же схемой; `state` защищает от
подмены запроса, но не от перехвата), меняется внешняя страница в
другом репозитории, и её текст «не читает данные авторизации» перестанет
быть правдой. Для выпуска не рекомендуется.

### C. ASWebAuthenticationSession

HTTPS-callback в сессии тоже требует Associated Domains → упирается в A.

## Что не делаем без решения

Не меняем страницу на GitHub Pages, entitlements, signing и Info.plist:
это внешний домен, подпись и модель безопасности (PLAYBOOK §14).
