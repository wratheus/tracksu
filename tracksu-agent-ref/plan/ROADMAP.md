# Очередь переработки Tracksu

2026-09-04 · единственный реестр этапов и их сводных статусов.

## Сейчас

В работе **P00.1**: read-only inventory identity, подписи, старой сборки,
локальных данных и store status. Его фактическое состояние — в карточке.
Изменения desktop/web и тестового файла в git — пользовательские, не результат
этого плана. Ветки, коммиты, зависимости и SDK в рамках подготовки не менялись.

## Очередь

Идём сверху вниз, одну выбранную часть за раз. Ссылка ID открывает её содержание;
большую часть перед стартом дробим, например P09.1. Пустые карточки заранее не создаём.

| ID / детали | Часть | Проверяемый результат | Статус |
| --- | --- | --- | --- |
| [P00](DETAILS.md#p00) · [P00.1](work/P00.1.md) | Релиз, подпись, локальные данные, старые сборки | Подтверждены идентификаторы, ключи, статус магазинов и доступный baseline | in_progress |
| [P01](DETAILS.md#p01) | Уточнение TSD-референса, ADR, карта экранов и прав на assets | Согласованы package graph, границы feature/UI kit, scope и отличия от TSD | backlog |
| [P01.1](DETAILS.md#p01-1) | Новый нейминг и карта product/developer identity | Выбраны новые публичные имена, package prefix и план ребрендинга; store/account решение отделено от названия | backlog |
| [P01.2](DETAILS.md#p01-2) | Аудит и рационализация bundled assets | У каждого ресурса есть provenance/licence, usage и размер; лишнее, дубли и неподходящие форматы имеют решение remove/replace/retain | backlog |
| [P02](DETAILS.md#p02) · [toolchain](work/P02-toolchain.md) | Flutter/Dart, Pub workspace, матрица plugins, технический CI | Pin candidate выбран; Flutter workspace поднят в root, далее FVM pin, единый workspace/lockfile и CI | in_progress |
| [P02.1](DETAILS.md#p02-1) | README, документация проекта и CHANGELOG | Актуальная точка входа для разработчика, структура технической документации и журнал реальных изменений | backlog |
| [P03](DETAILS.md#p03) · [P03.2](work/P03.2.md) | Android build, namespace/Kotlin и системные интеграции | Новый ID и Flutter 3.47.2 Gradle layer введены; production signing, native build и device checks остаются | in_progress |
| [P04](DETAILS.md#p04) | iOS host и SPM | Симулятор/устройство запускают shell; восстановлены signing/capabilities; проверен archive | backlog |
| [P05](DETAILS.md#p05) | GitHub Pages, собственный OAuth callback и контракт API v2 | Проверены старые зависимости; выбран вариант возврата/необходимость сайта, описаны flow/scopes; пользователь проверяет доступный auth spike | backlog |
| [P05.1](DETAILS.md#p05-1) · [карточка](work/P05.1-di.md) | DI и bootstrap по TSD — отдельная часть | registerDependencies, DepsContainer/DepsScope, явный lifetime и локальное wiring feature; основа для следующих частей | awaiting_manual_check |
| [P06](DETAILS.md#p06) | Clean/DDD foundation и лёгкий REST-клиент | `http` выбран; transport через DI, отмена и hooks готовы. Дальше — один source/repository без полного копирования TSD | in_progress |
| [P06.1](DETAILS.md#p06-1) | Firebase Analytics: единый клиент и контракт действий | Типизированные события, безопасный контекст, отключение сбора и простой способ подключения к UI kit/feature | backlog |
| [P07](DETAILS.md#p07) | UI kit и единая темизация | Light/dark tokens, app ThemeMode, базовые компоненты, mobile-only shell и каталог примеров | backlog |
| [P07.1](DETAILS.md#p07-1) | Обязательная localization foundation | Отдельный l10n package, ARB, locale resolution/выбор языка, fallback и правила перевода каждой feature | backlog |
| [P08](DETAILS.md#p08) | Auth/session и миграция secure storage | TokenStore, session restore, bearer, code exchange, persistent callback state, refresh, one-shot 401 retry, local logout UI, `SessionStatus`, guest-first root и удаление legacy login entry готовы; legacy migration и ручный flow остаются | in_progress |
| [P09](DETAILS.md#features) | Первая feature: шапка и статистика профиля | Public profile lookup (`/users/{user}/{mode}`), typed ID/username, repository и scoped Bloc готовы; UI, четыре ruleset, refresh и ошибки остаются | in_progress |
| [P10](DETAILS.md#features) | Scores и списки карт профиля | Независимые состояния секций, пагинация, устойчивость к пустым/новым данным | backlog |
| [P11](DETAILS.md#features) | Рейтинги | Фильтры и страницы без гонок, пропавших строк и сброса позиции | backlog |
| [P12](DETAILS.md#features) | Beatmap и leaderboard | Типизированные ID/маршруты, корректные score/mods и возвращение назад | backlog |
| [P13](DETAILS.md#features) | Новости и HTML-контент | Список/ссылки/ошибки; определены обработка HTML и допустимые URL-схемы | backlog |
| [P14](DETAILS.md#features) | Audio preview, если подтверждены права | Один владелец player, корректные lifecycle/audio focus; либо явный перенос feature в backlog | backlog |
| [P16](DETAILS.md#p16) | Legacy cleanup | Только подтверждённо заменённые пути, imports, assets и packages удалены отдельными маленькими commit'ами | backlog |
| [P15](DETAILS.md#p15) | Ручная регрессия пользователем и подготовка выпуска | Обновление поверх старого релиза, исправления лишних обновлений, licences/privacy и пакет для beta | backlog |
| [P17](DETAILS.md#p17) | BFF и серверный OAuth callback — после client MVP | Backend владеет client secret и OAuth callback/token exchange; mobile binary не содержит secret, rollout и rollback проверены отдельно | backlog |
| [T01](DETAILS.md#t01) | Автоматические тесты — отдельная отложенная часть | Не начата и не выполняется параллельно с P00–P16; объём/время старта выбираются отдельно | deferred |

Статусы: backlog → ready → in_progress → awaiting_manual_check → verified.
Deferred — отдельно отложено. Blocker и его причина записываются в карточке;
проверенная часть работы не означает завершения всей задачи. Ручное подтверждение
пользователя нужно для verified поведения; технические результаты не выдумываем.

## Что читать для выбранной части

| Задача | Материалы в дополнение к её деталям |
| --- | --- |
| Любая реализация | [Рабочий цикл и коммиты](../workflow/PLAYBOOK.md), [выбор skills](../standards/SKILLS.md) |
| P00–P01.2 | [Исходный аудит](DETAILS.md#baseline), [сохранение identity](DETAILS.md#p00), [права](DETAILS.md#rights), [TSD](../reference/TSD.md) |
| P02–P04 | [Стиль/analyzer](../standards/CODE_STYLE.md), [удаляемые пакеты/native assets](../standards/DEPENDENCIES.md) |
| P05, P08 | [OAuth callback](../reference/AUTH_CALLBACK.md), [API contract](DETAILS.md#api), [upgrade данных](DETAILS.md#p08) |
| P05.1, P06 | [TSD DI/package boundaries](../reference/TSD.md), [лёгкий REST](../standards/DEPENDENCIES.md) |
| P06.1 | [Аналитика и privacy](DETAILS.md#p06-1), Lichi-референс в [TSD](../reference/TSD.md) |
| P07–P14 | [UI kit](DETAILS.md#p07), [l10n](DETAILS.md#p07-1), [API](DETAILS.md#api), правила Bloc/UI/rebuild в регламенте |
| P15 | [Release](DETAILS.md#p15), результаты ручных проверок из карточек, rights/privacy и upgrade |
| T01 | Не открывать в работу без отдельного выбора пользователя |

## Что ещё предстоит выбрать

Эти решения принимаются внутри соответствующих частей, не блокируют чтение плана:

- P00: доступность подписей/старой сборки, статус магазинов, путь обновления.
- P01/P01.1/P01.2: scope платформ/функций, имена и package prefix,
  UI-направление, языки/рынки, права и рациональность используемых assets.
- P02–P04: конкретный SDK/toolchain и совместимые plugins/native settings.
- P05: допустимый OAuth callback, необходимость своего HTTPS landing и контракт
  API; PKCE/custom scheme не считать поддержанными без проверки.
- P06: http либо Dio и достаточный scope REST; BFF не входит в client MVP.
- P06.1: event catalog, безопасные параметры, privacy/consent и окружения Firebase.
- P14/P15: права/необходимость audio, готовность релиза и отдельное разрешение
  на публикацию, внешние обращения и ротацию credentials.
- P17: домен/hosting, server stack и data/privacy obligations для BFF; не
  создавать backend как побочный эффект client refactor.

## Как взять первую часть

Предлагаемый первый узкий шаг — P00.1: read-only inventory identity, signing
materials (только наличие/место хранения, без значений), старой сборки, локальных
данных и store status. Результат — список подтверждённых фактов/неизвестного
и план сохранения, а не пересозданные android/ios.

После выбора пользователя создать `plan/work/P00.1.md` по
[шаблону](../workflow/PLAYBOOK.md#task-template), дать ссылку на карточку в строке
P00. Перед реализацией записать scope, commit plan, проверки и recovery. Не
объявлять P00 ready, пока его входные условия не проверены. Следующую часть
без выбора не начинать.

## Поддержка документов

Статус этапа — только в этой таблице; фактический прогресс/коммиты/проверки/ADR/
handoff — в его карточке. Содержание этапа — DETAILS; стандарт — свой профильный
документ. Обновлять место-владелец, а не копировать новые требования по всем файлам.
Общий запрет автотестов и границы полномочий — в регламенте и маршрутизаторе skills.
