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
  - Compilación verificada (2026-11-27, Xcode 26.4, rama `fix/review-T-011`): `xcodebuild -scheme MyNeuroUI-Package` con destino iPhone 15 Pro (iOS 17.4) termina con `BUILD SUCCEEDED` (`-target arm64-apple-ios17.0-simulator`, SDK 26.4). Solo compilación: no se ha ejecutado la app en un runtime de iOS 17.4.
- [x] T-003 `NeumorphicInset` en Core + tests + ADR-002 (`feat/T-003-neumorphic-inset`)
  - Prueba manual del propietario (2026-11-27, app `NeuroPlayground,` con `InsetView`, paquete local en `fix/review-T-011`, simulador iPhone 17 Pro, iOS 26.4): todo OK. `.neumorphicInset()` en rectángulo redondeado y `Capsule`, dentro de `ScrollView` y de `List`: la sombra interior no se recorta, ni en reposo ni al entrar y salir de pantalla; también en modo oscuro.
- [x] T-004 Tema por `Environment` + ADR-003 (`feat/T-004-theme-environment`)
- [x] T-005 Modo oscuro en `NeumorphicTheme` (`feat/T-005-dark-mode`)
- [x] T-006 Extraer `NeuroPressable` (`feat/T-006-neuro-pressable`)
- [x] T-007 `NeuroCard` (`feat/T-007-neuro-card`)
- [x] T-008 `NeuroBadge` / `NeuroDivider` (`feat/T-008-badge-divider`)
  - Prueba manual del propietario de T-007 y T-008 (2026-11-27, app `NeuroPlayground,` con `CardView`, paquete local en `fix/review-T-011`, simulador iPhone 17 Pro, iOS 26.4): todo OK con contenido real y Dynamic Type grande. Tarjeta con texto largo, badges con icono y color, badge con texto muy largo, divisor horizontal y vertical, tarjeta anidada, sombras al hacer scroll y modo oscuro.
- [x] T-009 `NeuroProgress` (`feat/T-009-neuro-progress`)
  - Prueba manual del propietario (2026-11-27, app `NeuroPlayground,` con `ProgressView2`, paquete local en `fix/review-T-011`, simulador iPhone 17 Pro, iOS 26.4): todo OK. Valores 0, 1 y fuera de rango (-0.3 y 1.7) en barra y anillo, surco del anillo, anillo fino (4) y grueso (30), y modo oscuro con `.neumorphicTheme()`.
- [x] T-010 `NeuroSlider` (`feat/T-010-neuro-slider` + `fix/review-T-010`; arrastre solo verificado por lógica pura, no con dedo real; tvOS solo compila)
  - Prueba manual del propietario (2026-11-27, app `NeuroPlayground,` con el paquete local en `fix/review-T-011`, simulador iPhone 17 Pro, iOS 26.4):
    - Arrastre con paso: OK. "Paso 0.1" marcó 0,6 y "Rango 20…80" con paso 5 marcó 65, sin ruido de coma flotante.
    - Accesibilidad en Accessibility Inspector: OK. Etiqueta "Volumen", valor "61 %", rasgo Adjustable y acciones Increment/Decrement. Increment y Decrement funcionan y cambian el valor.
    - Sin probar todavía: arrastre desde cualquier punto de la pista, límites, dentro de `ScrollView`, derecha a izquierda, VoiceOver real en iPhone (T-032) y mando de tvOS.
- [x] T-011 `NeuroSegmentedControl` (`feat/T-011-segmented-control`; toque y animación de la píldora solo verificados por lógica y render, sin revisión independiente todavía)
  - Prueba manual del propietario (2026-11-27, app `NeuroPlayground,` con `SegmentView`, paquete local en `fix/review-T-011`, simulador iPhone 17 Pro, iOS 26.4): todo OK. Píldora deslizante, área de toque completa, títulos largos, 6 segmentos, solo iconos, "Reducir movimiento" y VoiceOver (Accessibility Inspector).
    - Sin probar todavía: Dynamic Type con tamaños de texto grandes (T-031) y VoiceOver real en iPhone (T-032).
- [ ] T-012 `NeuroTextField`
- [ ] T-013 `NeuroStepper` / `NeuroTabBar`
- [ ] T-014 Accesibilidad transversal
- [ ] T-015 Prueba en ScrollView/List (recorte de sombras)
  - Avance: `NeumorphicInset` ya probado dentro de `ScrollView` y `List` sin recorte (ver T-003), y `NeuroCard`/`NeuroBadge`/`NeuroDivider` en `ScrollView` (ver T-008). Falta probar las sombras externas de `NeumorphicSurface` (`NeuroToggle`, `MyNeuroButton`) y `NeuroSlider` dentro de `List` y de `ScrollView`.
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
- [x] T-019 (`feat/T-019-inset-shape`) `NeumorphicInset` pasó a ser genérico sobre la forma (`.neumorphicInset(in:theme:)`); `NeuroProgress` usa `Capsule` y `RingShape` y ya no dibuja sombras a mano ni copia el tema para cambiar `cornerRadius`. Ver ADR-002.
- [x] T-020 (`feat/T-020-theme-property`) Todos los componentes comparten la convención de ADR-003: `public var theme: NeumorphicTheme` no opcional (explícito o `.default`). Ver ADR-003.
- [ ] T-021 **Decidir** si se hace público un único helper de resolución de tema en Core (hoy `theme ?? environmentTheme` se repite en 4 componentes; `NeuroPressable.resolve` es interno).
- [ ] T-022 Constantes mágicas: topes de sombra de `cappingShadow(at:)` (badge 4, pomo del slider 5, píldora del segmented 5; además espaciado 6, opacidad 0.6 y relleno de pista 4 de `NeuroSegmentedControl`), opacidades 0.25/0.8 del divider y 0.3/0.8 de las sombras. Pasarlas a tokens o a una única fuente en Core.
- [ ] T-023 `reduceMotion`: `NeuroProgress`, `NeuroToggle` y `NeuroSlider` animan siempre (`NeuroSegmentedControl` ya respeta `reduceMotion`); leer `accessibilityReduceMotion` (encaja con T-014).
- [ ] T-024 Test helper `pixels` repetido en 5 archivos de test: moverlo a un `TestSupport.swift` por target.
- [ ] T-025 Docs: añadir los 5 componentes nuevos (incluido `NeuroSlider`) al árbol y a "Public API" de CLAUDE.md, (incluido en T-018); el ADR-002 ya cubre la técnica del anillo y `cappingShadow(at:)` está descrito en "Piezas clave".
- `NeuroProgress` debería formatear su valor de accesibilidad con `.percent` como hace `NeuroSlider` (localizado) en vez de "N percent" fijo (hallado en T-010; parte de T-014).

## Hallazgos de la revisión independiente de T-019, T-020 y T-010
Corregidos en `fix/review-T-010`: el arrastre ignoraba `layoutDirection` (en derecha-a-izquierda el pomo saltaba al lado contrario), ruido de coma flotante en `snapped` (0.30000000000000004 con paso 0.1), el pomo podía quedarse hundido si SwiftUI cancelaba el gesto (ahora `@GestureState`), `step!` sin desempaquetar de forma segura, test vacío del binding eliminado, aviso de scroll/sombras en la documentación y comentario de `theme` unificado en `NeuroToggle` y `MyNeuroButton`.
- [ ] T-026 tvOS: `NeuroSlider` es `focusable()` pero no muestra foco; añadir indicador visual (p. ej. `@Environment(\.isFocused)` en una vista hija) y probarlo en un Apple TV o simulador.
- [ ] T-027 `NeuroSlider` y `NeuroSegmentedControl` sin `accessibilityLabel` de grupo; el slider sin etiqueta por defecto: VoiceOver solo dice "ajustable, 50 %". `NeuroProgress` sí tiene "Progress". Decidir una política común (T-014).
- [ ] T-028 Nombres de tamaño inconsistentes: `NeuroSlider` usa `trackHeight`/`knobSize`, `NeuroProgress` usa `thickness` y `NeuroToggle` usa `width`/`height`. Decidir si se unifican.
- [ ] T-029 `NeuroBadge` y `NeuroSegment` (y `titles:` de `NeuroSegmentedControl`) reciben `String`, no `LocalizedStringKey`: no se pueden localizar por clave.
- [ ] T-030 Tests que faltan: ruta arrastre → binding (no testeable sin un gesto real; valorar una prueba de interfaz) y comportamiento del slider dentro de `ScrollView`/`List` (junto a T-015).

## Hallazgos de la revisión independiente de T-011
Corregidos en `fix/review-T-011`: con valores de segmento repetidos el control se rompía (un segmento no se dibujaba y aparecía una píldora sin etiqueta; ahora se identifican por posición y solo se resalta el primero), el área pulsable de un segmento no seleccionado era solo el texto (añadido `contentShape`), `reduceMotion` ignorado, `segmentHeight` ausente del init `titles:`, y documentación (sombras, selección sin coincidencia, duplicados).
- [ ] T-031 Dynamic Type en `NeuroSegmentedControl`: `lineLimit(1)` recorta títulos con tamaños grandes; valorar `minimumScaleFactor` o disposición vertical (parte de T-014).
- [ ] T-032 Verificar en un dispositivo que VoiceOver anuncia "seleccionado" en el segmento activo (el rasgo está sobre un `Button`).
- [x] T-035 (`fix/tvos-focus-indicator`) tvOS: `NeuroToggle` y `MyNeuroButton` no mostraban foco (probado por el propietario en el simulador: «no se ve ningún foco»). `NeuroPressable` agranda el control un 10 % mientras tiene foco y quita el borde blanco del sistema (estilo de botón propio en tvOS: `focusEffectDisabled` solo no bastaba), que era grande y no seguía la forma del botón (visto por el propietario en el simulador; el Canvas de Xcode no muestra el foco). Solo compila y se prueba su lógica; el aspecto real hay que verlo en el simulador. `NeuroSlider` sigue pendiente (T-026).
- [ ] T-033 Tests que faltan en `NeuroSegmentedControl`: estado pulsado (opacidad 0.6) y cambio de selección con un binding con estado.
