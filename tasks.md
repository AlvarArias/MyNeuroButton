# tasks.md

Una tarea = una rama `feat/T-xxx-nombre`. Estado: [ ] pendiente, [~] en curso, [x] hecho.

## Fase 0 — Estructura de agente
- [x] F0-1 SPEC, ARCHITECTURE, tasks, AGENTS (`chore/F0-1-project-docs`)
- [ ] F0-2 Ampliar CLAUDE.md (workflow y reglas duras)
- [ ] F0-3 `.claude/agents/` y `docs/reviews/`
- [x] F0-4 Linter/formatter y `.githooks` (rama `chore/F0-4-lint-hooks`; el lint solo avisa: quedan diffs de formato en NeuroToggle, MyNeuroButton y NeumorphicSurface)
- [x] F0-5 CI iOS/tvOS (ya resuelto upstream en `e1625ca`)

## Fases de producto
- [x] T-001 Revisar APIs de iOS 26 usadas (`feat/T-001-platform-api-audit`)
  - Resultado: ninguna API exclusiva de 26. Se usa `Button`, `onLongPressGesture`, `foregroundStyle`, `scaleEffect`, `shadow`, `Color(red:)`.
  - Verificado compilando `MyNeuroUI-Package` para iOS Simulator, tvOS Simulator y macOS con mínimos iOS 15/macOS 12/tvOS 15, 16/13/16 y 17/14/17: los tres compilan.
  - Para T-004: `@Entry` requiere Xcode 16+ pero hace back-deploy.
- [x] T-002 Decidir mínimo de plataforma (y visionOS) + ADR-004 (`feat/T-002-platform-minimum`): iOS 17 / macOS 14 / tvOS 17, visionOS no por ahora
- [x] T-003 `NeumorphicInset` en Core + tests + ADR-002 (`feat/T-003-neumorphic-inset`)
- [x] T-004 Tema por `Environment` + ADR-003 (`feat/T-004-theme-environment`)
- [x] T-005 Modo oscuro en `NeumorphicTheme` (`feat/T-005-dark-mode`)
- [ ] T-006 Extraer `NeuroPressable`
- [ ] T-007 `NeuroCard`
- [ ] T-008 `NeuroBadge` / `NeuroDivider`
- [ ] T-009 `NeuroProgress`
- [ ] T-010 `NeuroSlider`
- [ ] T-011 `NeuroSegmentedControl`
- [ ] T-012 `NeuroTextField`
- [ ] T-013 `NeuroStepper` / `NeuroTabBar`
- [ ] T-014 Accesibilidad transversal
- [ ] T-015 Prueba en ScrollView/List (recorte de sombras)
- [ ] T-016 README con galería + release
- [ ] T-017 Aplicar `swift format` a NeuroToggle, MyNeuroButton y NeumorphicSurface y pasar el lint a `--strict` en el hook (viene de F0-4)
- [ ] T-018 Sincronizar la sección "Public API" de CLAUDE.md con la API de la Fase 1

## Hallazgos fuera de alcance
(añadir aquí líneas en vez de arreglarlas en otra tarea)
- README dice Xcode 16+ pero `swift-tools-version: 6.2` exige Xcode 26; corregir el README o bajar tools-version (hallado en T-002).
- CLAUDE.md "Public API" sigue describiendo el tema antiguo: sincronizar con `NeumorphicInset`, `neumorphicTheme` (Environment), `.dark` y los tokens nuevos (T-018, hallado al cerrar la Fase 1).
