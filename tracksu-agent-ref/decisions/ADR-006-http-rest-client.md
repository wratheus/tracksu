# ADR-006: лёгкий REST-клиент на `http`

2026-09-04 · принято.

## Контекст

Legacy `requests.dart` вызывает `http` напрямую из единого файла, смешивая
endpoint, HTTP-статусы, JSON-модели и auth. Для следующей архитектуры нужна
узкая transport boundary и один app-owned client, но текущие osu! endpoints не
требуют upload/download, multipart, server envelope или полного набора
интерцепторов TSD/Dio.

## Решение

Оставляем `http ^1.6.0` и добавляем workspace package `tracksu_network`.
`HttpRestClient` получает `http.Client` и HTTPS base URI через DI, закрывает
его при teardown container и предоставляет:

- отдельные `get`, `post`, `put`, `patch`, `delete`, `head`, `options`; у
  методов с body есть JSON/form choice, у всех — headers/query/options;
- typed raw `RestResponse` без JSON-моделей;
- timeout и typed cancellation/timeout/transport errors со stack trace;
- `RestCancellationToken`, подключённый к `http.AbortableRequest`;
- небольшие request/response interceptor hooks для общих безопасных политик.

Первый interceptor — `OsuApiHeadersInterceptor`: он задаёт API v2 response
version и JSON accept-header. Bearer token и refresh не входят в него до P08,
чтобы transport не получал credentials из UI/storage.

Interceptor не управляет UI, не логирует credential/body и не реализует
универсальные retries. Status-code mapping и JSON parsing остаются у remote
source/repository соответствующей feature.

## Последствия и границы

Первая поставка не мигрирует legacy endpoints: это сохраняет маленький и
обратимый commit. Следующим consumer станет один API source/repository; OAuth
refresh, повтор допустимых запросов и параллельные 401 принадлежат P08. При
отмене transport прекращает операцию там, где её поддерживает adapter; feature
также обязана игнорировать устаревший результат по lifecycle/query token.
