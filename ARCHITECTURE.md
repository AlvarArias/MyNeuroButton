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
- Previsto: `NeumorphicInset` (superficie hundida), tema por `Environment`, `NeuroPressable` interno.

## Patrón de componente
`@MainActor struct Neuro<Nombre>: View`, parámetro `theme`, estado de presión con `onLongPressGesture(minimumDuration: 0)` (no `ButtonStyle`), estilo solo vía modifiers de Core. En tvOS el feedback lo da el focus engine.

## ADRs
### ADR-001 — Core separado de UI
Estado: aceptada. Los tokens y modifiers viven aparte para reutilizarlos sin arrastrar componentes.

### ADR-002 — Modifier de sombra interior (pendiente, T-003)
Los componentes "hundidos" (TextField, Slider, Progress) necesitan un modifier inset en Core en vez de sombras propias.

### ADR-003 — Tema por Environment (pendiente, T-004)
Evita pasar `theme:` a cada componente en una app; `theme:` explícito queda como override.

### ADR-004 — Mínimo de plataforma (pendiente, T-002)
Bajar de 26 a 17/18 si no se usan APIs de 26. Subir/bajar el mínimo es cambio de contrato: requiere ADR y versión major si se sube.

## Versionado
SemVer. Añadir API = minor. Subir mínimo de plataforma o quitar `MyNeuroButton` = major.
