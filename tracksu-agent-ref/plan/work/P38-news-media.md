# P38 — видео, YouTube и много треков в новостях

2026-10-04 · implemented in code / awaiting_manual_check.

## Что было

- `<video>` и `<iframe>` → «Эта вставка доступна на исходной странице».
- Лимит 32 аудио на документ: «Featured Artist Track Updates: Winter 2026»
  содержит 36 `<audio>` — нормализатор бросал `FormatException`, и статья
  **не открывалась вовсе**.

Проверено по исходникам ppy/osu-wiki (`news/2025`, `news/2026`): аудио —
`<audio controls><source src="https://assets.ppy.sh/artists/{id}/…mp3">`,
видео — `<video controls><source src="https://assets.ppy.sh/…mp4">`,
iframe — YouTube, Twitch, Google Docs.

## Решение

См. [ADR-007](../../decisions/ADR-007-video-player.md).

- `ContentVideo` / `ContentEmbed` в `content_document.dart`; нормализатор:
  `<video>` (src или `<source>`) → видео только с assets.ppy.sh, иначе
  unsupported; `<iframe>` → embed (YouTube → watch-ссылка и превью).
- Лимит аудио 200, видео/встраиваний 32.
- `ContentVideoView` (`content_video.dart`): 16:9 с превью-постером,
  стеклянная кнопка, по нажатию загрузка; контролы по тапу (пауза/плей,
  время, перемотка, полный экран), автоскрытие при воспроизведении.
- `ContentEmbedCard` (`content_embed.dart`).
- Тест `test/src/_shared/content/content_normalizer_test.dart`.

## Проверить

- `fvm flutter pub get`, сборка iOS/Android.
- «New Featured Artist: adamyes» (2026-10-03): видео showcase и 3 трека.
- «Featured Artist Track Updates: Winter 2026»: статья открывается, 36 треков.
- Пост с YouTube: превью и переход в YouTube.
- Видео: пауза при уходе со страницы/в фон, полный экран и поворот.
