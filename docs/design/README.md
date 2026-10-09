# Design

- **Figma:** [Tracksu — UI kit & screens](https://www.figma.com/design/Vf4WdNVAaNjP9OjeA1CtVe)
  — colors (dark/light), osu! colors, typography, spacing/shape/motion,
  controls, app bar and navigation, sheets, lists, states, flows, and nine
  screens.
- **`tracksu-design.html`:** the same boards as one self-contained page; it is
  what was imported into Figma (open it in a browser).
- **`FLOWS.md`:** the main flows as Mermaid diagrams.
- **`src/`:** the generators (`python3 src/build_kit.py` etc. from `src/`).
  Tokens are copied by hand from `packages/tracksu_ui/lib/src/theme/`; update
  both when the theme changes.

The screens are mockups drawn from the app's tokens, not screenshots; mode
glyphs and avatars are stand-ins.

## Re-importing into Figma

The Figma connector creates a single-use upload URL; post the page to it:

```sh
curl -X POST "<submitUrl>" -H "Content-Type: text/html" \
  --data-binary @docs/design/tracksu-design.html
```
