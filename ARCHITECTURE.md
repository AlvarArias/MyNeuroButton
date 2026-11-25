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
- Tema por `Environment` (ADR-003), presets `.default` y `.dark` (ADR-005).
- Previsto: `NeuroPressable` interno.

## Patrón de componente
`@MainActor struct Neuro<Nombre>: View`, parámetro `theme: NeumorphicTheme? = nil` (cae al Environment), estado de presión con `onLongPressGesture(minimumDuration: 0)` (no `ButtonStyle`), estilo solo vía modifiers de Core. En tvOS el feedback lo da el focus engine.

## ADRs
### ADR-001 — Core separado de UI
Estado: aceptada. Los tokens y modifiers viven aparte para reutilizarlos sin arrastrar componentes.

### ADR-002 — Modifier de sombra interior (aceptada, T-003)
Los componentes "hundidos" (TextField, Slider, Progress) necesitan un modifier inset en Core en vez de sombras propias.
Decisión: `NeumorphicInset` (ViewModifier) + `View.neumorphicInset(theme:)`. Pinta como fondo del contenido un `RoundedRectangle(theme.cornerRadius)` relleno con `theme.background`, con dos trazos desenfocados y recortados a la forma: oscuro desplazado hacia dentro desde arriba-izquierda, claro desde abajo-derecha. Es el espejo de `NeumorphicSurface`.
Nuevo token `NeumorphicTheme.insetShadowRadius` (por defecto 5), añadido al final del `init` con valor por defecto, sin romper llamadas existentes. El desplazamiento es `insetShadowRadius / 2`.

### ADR-003 — Tema por Environment (aceptada, T-004)
Evita pasar `theme:` a cada componente en una app; `theme:` explícito queda como override.
Decisión: `EnvironmentValues.neumorphicTheme` (`@Entry`, por defecto `.default`) y `View.neumorphicTheme(_:)` para inyectarlo en un subárbol. `NeumorphicTheme` pasa a ser `Equatable`.
Los componentes cambian el parámetro `theme: NeumorphicTheme = .default` por `theme: NeumorphicTheme? = nil` (compatible a nivel de código fuente). Resolución: tema explícito si lo hay; si no, el del Environment. La propiedad pública `theme` sigue siendo `NeumorphicTheme` no opcional (devuelve el explícito o `.default`) para no romper a quien la lea.
Los modifiers `NeumorphicSurface` y `NeumorphicInset` siguen recibiendo el tema explícito; los componentes les pasan el ya resuelto.
Regla para componentes nuevos: `theme: NeumorphicTheme? = nil` + `@Environment(\.neumorphicTheme)`.

### ADR-005 — Modo oscuro por preset y modificador adaptativo (aceptada, T-005)
Decisión: no hacer los colores del tema "dinámicos". Se añaden dos tokens, `shadowColor` (por defecto `.black`) y `highlightColor` (por defecto `.white`), que `NeumorphicSurface` y `NeumorphicInset` usan en lugar de negro/blanco fijos. Se añade el preset `NeumorphicTheme.dark` (fondo oscuro, luz tenue) y el modificador `View.neumorphicTheme(light:dark:)`, que elige el tema según `colorScheme` e inyecta el resultado en el Environment (ADR-003).
Por qué: mantiene `NeumorphicTheme` como valor simple y `Equatable`, sin depender de UIColor/NSColor, y el modo oscuro es explícito (la app decide). El tema por defecto no cambia: ninguna app existente cambia de aspecto.
Las opacidades de las sombras siguen en los modifiers; el preset oscuro baja la intensidad de la luz con un `highlightColor` semitransparente.

### ADR-004 — Mínimo de plataforma: iOS 17 / macOS 14 / tvOS 17 (aceptada, T-002)
Contexto: el mínimo era 26 sin que ninguna API lo exigiera (T-001: compila hasta iOS 15/macOS 12/tvOS 15).
Decisión: bajar a iOS 17, macOS 14, tvOS 17. Bajar el mínimo no rompe a los consumidores actuales (cambio minor).
Por qué 17 y no menos: da acceso a `@Observable`, `sensoryFeedback`, `onChange` de dos parámetros y mejoras de gestos para los componentes de las fases siguientes, y cubre la mayoría de apps en uso.
visionOS: no se añade por ahora; no hay CI ni necesidad. Reabrir si una app lo pide.
Subir el mínimo en el futuro sí requiere nuevo ADR y versión major.

## Versionado
SemVer. Añadir API = minor. Subir mínimo de plataforma o quitar `MyNeuroButton` = major.
