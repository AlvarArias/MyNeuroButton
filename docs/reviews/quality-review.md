# Quality review checklist
- [ ] Module boundaries respected: only `NeumorphicCore` is imported by UI/legacy targets; no cross imports.
- [ ] No inline shadows/scale; styling goes through `NeumorphicSurface` / `NeumorphicInset`.
- [ ] No `AnyView`, no external dependencies.
- [ ] Naming: `Neuro<Name>`, lowerCamelCase members, `///` docs on public API.
- [ ] Accessibility: label, Dynamic Type, reduceMotion, acceptable contrast.
- [ ] Shadows are not clipped inside `ScrollView`/`List`.
- [ ] ARCHITECTURE.md/ADR, README and CLAUDE.md updated when structure or API changed.
- [ ] `tasks.md` updated; unrelated findings logged there, not fixed.
