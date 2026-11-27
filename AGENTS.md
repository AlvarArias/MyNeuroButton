# AGENTS.md

Instrucciones para cualquier agente de código. Fuente de verdad: `CLAUDE.md` (reglas y API), `SPEC.md`, `ARCHITECTURE.md`, `tasks.md`. Léelos antes de cambiar código.

- Una tarea de `tasks.md` por rama `feat/T-xxx-nombre`.
- Si cambias estructura o contrato, actualiza `ARCHITECTURE.md` (y ADR) antes del código.
- Tests junto al código. Verifica con `swift build && swift test`.
- Sin dependencias externas, sin sombras inline, sin `AnyView`.
- No amplíes el alcance: anota hallazgos ajenos en `tasks.md`.
- Nunca leas, imprimas ni subas credenciales.
