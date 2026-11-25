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
- [x] T-006 Extraer `NeuroPressable` (`feat/T-006-neuro-pressable`)
- [x] T-007 `NeuroCard` (`feat/T-007-neuro-card`)
- [x] T-008 `NeuroBadge` / `NeuroDivider` (`feat/T-008-badge-divider`)
- [x] T-009 `NeuroProgress` (`feat/T-009-neuro-progress`)
- [ ] T-010 `NeuroSlider`
- [ ] T-011 `NeuroSegmentedControl`
- [ ] T-012 `NeuroTextField`
- [ ] T-013 `NeuroStepper` / `NeuroTabBar`
- [ ] T-014 Accesibilidad transversal
- [ ] T-015 Prueba en ScrollView/List (recorte de sombras)
- [ ] T-016 README con galería + release
- [ ] T-017 Aplicar `swift format` a NeuroToggle, MyNeuroButton y NeumorphicSurface y pasar el lint a `--strict` en el hook (viene de F0-4)
- [ ] T-018 Sincronizar la sección "Public API" de CLAUDE.md con la API de las Fases 1 a 3 (incluye `NeuroCard`, `NeuroBadge`, `NeuroDivider`, `NeuroProgress` y `NeuroPressable`: CLAUDE.md aún dice que cada componente repite el gesto de pulsación y la receta "Adding a new component" no lo menciona)

## Hallazgos fuera de alcance
(añadir aquí líneas en vez de arreglarlas en otra tarea)
- README dice Xcode 16+ pero `swift-tools-version: 6.2` exige Xcode 26; corregir el README o bajar tools-version (hallado en T-002).
- CLAUDE.md "Public API" sigue describiendo el tema antiguo: sincronizar con `NeumorphicInset`, `neumorphicTheme` (Environment), `.dark` y los tokens nuevos (T-018, hallado al cerrar la Fase 1).
- `NeuroProgress` usa textos de accesibilidad fijos en inglés ("Progress", "N percent"): localizarlos y permitir `accessibilityLabel` propio (hallado en T-009; encaja con T-014).

## Hallazgos de la revisión independiente de T-007 a T-009 (pendientes de decisión)
Corregidos en `fix/review-T-007-T-009`: casos límite de `NeuroProgress` (grosor < 4, 0 o negativo; anillo más grueso que su marco), icono del badge oculto a VoiceOver, documentación `///` de los inits públicos y aviso de recorte de sombras.
- [ ] T-019 **Decidir** API de Core para el anillo: hoy `NeuroProgress.grooveShadows` dibuja sombras interiores a mano (duplica opacidades y offset de `NeumorphicInset`, contra ADR-002). Opciones: `neumorphicInset(theme:shape:)` genérico en Core, o un ADR que justifique la excepción.
- [ ] T-020 **Decidir** convención de la propiedad `theme`: `NeuroToggle`/`MyNeuroButton` exponen `NeumorphicTheme` no opcional (ADR-003); los 4 componentes nuevos exponen `NeumorphicTheme?`. Unificar y registrarlo en ADR-003.
- [ ] T-021 **Decidir** si se hace público un único helper de resolución de tema en Core (hoy `theme ?? environmentTheme` se repite en 4 componentes; `NeuroPressable.resolve` es interno).
- [ ] T-022 Constantes mágicas: tope de sombra del badge (4), opacidades 0.25/0.8 del divider y 0.3/0.8 de las sombras. Pasarlas a tokens o a una única fuente en Core. Valorar `cornerRadius:` explícito en `neumorphicInset` en vez de copiar el tema (ligado a T-019).
- [ ] T-023 `reduceMotion`: `NeuroProgress` y `NeuroToggle` animan siempre; leer `accessibilityReduceMotion` (encaja con T-014).
- [ ] T-024 Test helper `pixels` repetido en 5 archivos de test: moverlo a un `TestSupport.swift` por target.
- [ ] T-025 Docs: añadir los 4 componentes nuevos al árbol y a "Public API" de CLAUDE.md, y un ADR para la técnica del anillo y el patrón de copiar el tema (incluido en T-018).
