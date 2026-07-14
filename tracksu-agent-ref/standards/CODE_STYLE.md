# Dart/Flutter: единая политика стиля и analyzer

Редакция 1 · 2026-09-04 · подготовлено для P02, в приложении ещё не включено.

## Основа и статус

Пользователь передал `analysis_options.1.0.0.yaml` как основу для нового Flutter.
Это не только форматирование: файл задаёт строгую типизацию, lint rules и
уровни диагностик. Принимаем его как базу Tracksu вместо приватного
корпоративного analyzer package из TSD.

- [Исходник без изменений](../config/analysis_options.source.1.0.0.yaml) — копия
  пользовательского файла; сохраняется для сравнения, не подключается в app.
- [Адаптация для Tracksu](../config/analysis_options.tracksu.yaml) — будущая общая
  политика приложения и workspace packages. Имена правил сверены с текущим
  каталогом Dart 3.13; полная проверка на выбранной связке SDK/dependencies — P02.
- [ROADMAP](../plan/ROADMAP.md) определяет очередь, [регламент](../workflow/PLAYBOOK.md)
  — границы изменений и коммитов, [SKILLS](../standards/SKILLS.md) — дополнительные правила.

Активный `analysis_options.yaml`, pubspec и Dart-код сейчас не менялись.
Не запускались analyzer приложения, formatter, сборки, pub get или автотесты.
Проверка YAML и названий правил не означает, что legacy-код уже им соответствует.

## Что адаптировано относительно исходника

| Изменение | Причина / сохранённое намерение |
| --- | --- |
| `no_runtimeType_toString` → `no_runtimetype_tostring` | Актуальное имя проверки; запрещаем использовать строковое runtimeType как надёжный идентификатор |
| `iterable_contains_unrelated_type`, `list_remove_unrelated_type` → `collection_methods_unrelated_type: error` | Общая проверка уже включена в исходнике; сохраняем для неё уровень error вместо двух старых overrides |
| Убраны `always_require_non_null_named_parameters`, `avoid_returning_null_for_future`, `enable_null_safety`, `prefer_equal_for_default_values` | Старые правила отсутствуют в текущем каталоге. Используем sound null safety и современные required/default parameters, не отключаем диагностики языка |
| Убраны `unsafe_html`, `package_api_docs` | Этих правил нет в актуальном каталоге. Это не отменяет проверку HTML/URL безопасности на P13 и документацию публичных контрактов |
| Убраны overrides `missing_return: warning`, `missing_required_param: warning` | Не переносим legacy severity-настройки. Современные ошибки возврата non-null значения и обязательных аргументов остаются с уровнем SDK по умолчанию |
| Добавлено `formatter.page_width: 80` | Явно фиксируем стандартную ширину; алгоритм переносов определяется закреплённым SDK |
| Exclude patterns сделаны workspace-aware: `**/build/**`, `**/*.g.dart` и аналогичные | Покрываем вложенные пакеты и generated output, не только корень приложения |
| Удалён blanket exclude `scripts/**` | Рукописные Dart scripts/tooling также анализируются; shell scripts Dart analyzer не проверяет |
| Обновлены комментарии | Указаны статус шаблона и strict type checking вместо исторического strong mode |

Все остальные включения/отключения lints и severity сохранены. Не включаем
автоматически весь каталог новых правил и не снижаем строгость ради legacy.
Исходные комментарии Pedantic/Effective Dart обозначают происхождение групп,
а не требование установить эти старые пакеты.

Каталог и диагностики: [все актуальные lints](https://dart.dev/tools/linter-rules/all),
[collection_methods_unrelated_type](https://dart.dev/tools/linter-rules/collection_methods_unrelated_type),
[no_runtimetype_tostring](https://dart.dev/tools/linter-rules/no_runtimetype_tostring),
[missing_required_argument](https://dart.dev/tools/diagnostics/missing_required_argument).
Перечень правил перепроверяем при фактическом pin SDK; несовместимое правило
заменяем документированно, а не добавляем ignore на unknown lint.

## Форматирование и правила skills

Используем только `dart format` из выбранного FVM Flutter, в IDE и CI тот же SDK.
Отступы — стандартные два пробела, одинарные кавычки и import ordering задаются
lint rules. Formatter не заменяет analyzer и не сортирует за нас все imports.
`lines_longer_than_80_chars: false` сохраняется: ширина formatter — ориентир
переносов, не запрет на любую длинную строку/URL.

Сохраняем `require_trailing_commas: true`. Современный formatter сам управляет
запятыми и переносами; `trailing_commas: preserve` не включаем без отдельного
решения. Не расставляем ручные переносы вопреки formatter. См.
[настройки formatter](https://dart.dev/tools/dart-format) и
[правило trailing commas](https://dart.dev/tools/linter-rules/require_trailing_commas).

При адаптации применены `pavlenko-dart-style` и `pavlenko-flutter-ui`:

- Сохраняем strict casts/inference/raw types, package imports, final locals,
  явные типы на границах, типизированные ошибки/async и ownership ресурсов.
  Между пакетами — public barrel, а не чужой `lib/src`; `part`/`part of` —
  отдельные директивы, для которых допустимы относительные URI.
- `avoid_final_parameters: true` сохраняется для обычных параметров. Новый
  синтаксис объявления полей в constructor из TSD сверяем с выбранным SDK и
  analyzer; при конфликте используем обычное final-поле и initializing formal,
  а не отключаем lint глобально ради буквального копирования синтаксиса TSD.
- `sized_box_for_whitespace: true` сохраняется как проверка тяжёлого пустого
  Container. Для промежутков между детьми выбираем `Row/Column.spacing` или
  Padding согласно UI skill; не принимаем автозамену на пустой SizedBox-gap.
  SizedBox для реальных constraints и shrink остаётся допустимым.
- `do_not_use_environment: true` сохраняется. Если P02 использует fromEnvironment
  для AppConfig, единственный configuration boundary получает узкое обоснованное
  исключение с ADR; feature/domain не читают environment сами. Альтернатива —
  typed generated config. Это не делает credentials секретными в бинарнике.
- Excludes для `*.config.dart` и других suffixes допустимы только для реально
  генерируемых файлов. Рукописный AppConfig и другие исходники нельзя прятать
  под исключённым suffix; пути генерации проверяем на P02 и при добавлении codegen.
- Отсутствие lint на DDD, границы rebuild, локализацию или аналитику не отменяет
  требования регламента. Эти ограничения проверяются при review выбранной части.

## Подключение в P02 небольшими частями

1. Зафиксировать SDK/Flutter и совместимую версию `flutter_lints` в
   dev_dependencies workspace root и lockfile. Сейчас legacy YAML уже содержит
   include flutter_lints, но legacy pubspec не объявляет эту dev dependency.
   Это нужно исправить при подключении, не рассчитывать на транзитивное наличие.
2. Разместить адаптацию как активный `analysis_options.yaml` в согласованном
   workspace root. App и `packages/*` наследуют одну политику. Удаление старого
   вложенного override/его замена на include — отдельная проверенная часть.
   Если package-level конфиг нужен, он включает корневой по фактическому пути,
   а не дублирует сотни правил. Проверить effective rules из app и каждого пакета.
   Для пакетов, которые станут автономными вне workspace, dependency/include
   разрешение проверяется отдельно; не вводим такую поддержку заранее.
3. Выполнить analyzer после разрешения зависимостей: нет unknown/removed rules,
   unresolved include и неожиданных overrides. Снять список legacy-нарушений
   отдельно от новых. Строгость нового кода действует сразу; старый долг имеет
   явно ограниченный scope и задачи устранения, а не глобальный ignore.
4. Formatter, imports и безопасные механические lint fixes делать небольшими
   коммитами по согласованным файлам/пакетам. Изменения типов, async/lifecycle,
   state или поведения — отдельные смысловые части. Не запускать root-wide
   `dart fix --apply` / `dart format .` на весь legacy в одном коммите.
5. Добавить scoped format check/analyze в технический CI с явным списком
   проверяемых handwritten paths. Не предполагать, что analyzer.exclude сам
   определяет охват formatter. Generated-файлы не править вручную; правило их
   проверки и генерации фиксируется отдельно. Временный scope CI описать честно,
   расширять по мере миграции, не объявлять весь repo чистым по проверке одной папки.
6. Вместе с подключением обновить этот документ, README и журнал P02, затем
   поддерживать изменения политики в том же логическом коммите. После активации
   runtime-конфиг — источник действующих правил; шаблон и пояснения не расходятся.

До реализации составляем конкретный commit plan по разделу 15.1 регламента.
Если смена SDK и analyzer dependency технически неразделима, допускается один
согласованный совместимый шаг; массовый перенос feature к нему не добавляется.

Готовность подключения: одна разрешимая policy для app/packages, закреплённые
SDK/lint dependencies, отсутствие неизвестных настроек, описанные legacy debt
и scope CI, небольшие проверяемые изменения. Автотесты не писать, не менять и
не запускать: упоминание `use_test_throws_matchers` в исходных lints не запускает
T01; `test_types_in_equals` вообще проверяет реализацию equality, не test suite.
