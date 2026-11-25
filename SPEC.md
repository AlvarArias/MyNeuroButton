# SPEC — MyNeuroUI

## Propósito
Librería SwiftUI (Swift Package) de componentes neumórficos reutilizables en cualquier app Apple, con un sistema de tokens de diseño compartido.

## Alcance (dentro)
- Tokens (`NeumorphicTheme`), modifiers de superficie (elevada y hundida) y extensiones de `Color` en `NeumorphicCore`.
- Componentes en `NeumorphicUI`: `NeuroToggle` (existe) y los previstos en `tasks.md` (Card, Badge, Divider, Progress, Slider, SegmentedControl, TextField, Stepper, TabBar).
- Plataformas: iOS, macOS, tvOS (mínimo actual 26; ver T-002).
- Tests unitarios por componente.

## Fuera de alcance
- Dependencias externas.
- Navegación, networking, persistencia, lógica de negocio.
- UIKit/AppKit: solo SwiftUI.

## Requisitos transversales
1. Cada componente acepta `theme: NeumorphicTheme` (o lo toma del `Environment` cuando exista, T-004).
2. Sombras y escala solo vía `NeumorphicSurface` / `NeumorphicInset`; nunca inline.
3. Sin `AnyView`; vistas fuertemente tipadas.
4. Accesibilidad: `accessibilityLabel`, Dynamic Type, `reduceMotion`.
5. Todo API público nuevo lleva tests XCTest.
6. `MyNeuroButton` (legacy) y el init `iconFull` se conservan hasta el próximo major.

## Criterios de aceptación por componente
- Compila y pasa tests en macOS (`swift test`) y compila para iOS y tvOS.
- Valores por defecto razonables y documentados con `///`.
- Se ve correcto dentro de `ScrollView`/`List` (sin recorte de sombras).
- Tests: init, valores por defecto, binding/acción.
