# ARCHITECTURE — MyNeuroUI

## Targets y dependencias
```
NeumorphicCore   (sin deps)   tokens, ViewModifiers, Color
      ↑
      ├── NeumorphicUI        componentes nuevos
      └── MyNeuroButton       legacy (compat)
```
Reglas:
- `NeumorphicCore` no importa ningún otro target.
- `NeumorphicUI` y `MyNeuroButton` solo dependen de `NeumorphicCore`; no se importan entre sí.
- Componentes nuevos van siempre en `NeumorphicUI`.
- Cero paquetes externos.

## Piezas clave
- `NeumorphicTheme` (struct `Sendable`): fondo, foreground, radios, duración de animación, radios de sombra.
- `NeumorphicSurface`: superficie elevada/presionada (escala + par de sombras).
- `NeumorphicInset`: superficie hundida (sombra interior). Para TextField, Slider y Progress.
- Previsto: tema por `Environment`, `NeuroPressable` interno.

## Patrón de componente
`@MainActor struct Neuro<Nombre>: View`, parámetro `theme`, estado de presión con `onLongPressGesture(minimumDuration: 0)` (no `ButtonStyle`), estilo solo vía modifiers de Core. En tvOS el feedback lo da el focus engine.

## ADRs
### ADR-001 — Core separado de UI
Estado: aceptada. Los tokens y modifiers viven aparte para reutilizarlos sin arrastrar componentes.

### ADR-002 — Modifier de sombra interior (aceptada, T-003)
Los componentes "hundidos" (TextField, Slider, Progress) necesitan un modifier inset en Core en vez de sombras propias.
Decisión: `NeumorphicInset` (ViewModifier) + `View.neumorphicInset(theme:)`. Pinta como fondo del contenido un `RoundedRectangle(theme.cornerRadius)` relleno con `theme.background`, con dos trazos desenfocados y recortados a la forma: oscuro desplazado hacia dentro desde arriba-izquierda, claro desde abajo-derecha. Es el espejo de `NeumorphicSurface`.
Nuevo token `NeumorphicTheme.insetShadowRadius` (por defecto 5), añadido al final del `init` con valor por defecto, sin romper llamadas existentes. El desplazamiento es `insetShadowRadius / 2`.

### ADR-003 — Tema por Environment (pendiente, T-004)
Evita pasar `theme:` a cada componente en una app; `theme:` explícito queda como override.

### ADR-004 — Mínimo de plataforma: iOS 17 / macOS 14 / tvOS 17 (aceptada, T-002)
Contexto: el mínimo era 26 sin que ninguna API lo exigiera (T-001: compila hasta iOS 15/macOS 12/tvOS 15).
Decisión: bajar a iOS 17, macOS 14, tvOS 17. Bajar el mínimo no rompe a los consumidores actuales (cambio minor).
Por qué 17 y no menos: da acceso a `@Observable`, `sensoryFeedback`, `onChange` de dos parámetros y mejoras de gestos para los componentes de las fases siguientes, y cubre la mayoría de apps en uso.
visionOS: no se añade por ahora; no hay CI ni necesidad. Reabrir si una app lo pide.
Subir el mínimo en el futuro sí requiere nuevo ADR y versión major.

## Versionado
SemVer. Añadir API = minor. Subir mínimo de plataforma o quitar `MyNeuroButton` = major.
