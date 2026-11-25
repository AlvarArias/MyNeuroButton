# Code review checklist
- [ ] Does the change do exactly what the task in `tasks.md` says, no more?
- [ ] Public API additions have XCTest cases (init, defaults, binding/action).
- [ ] Bindings, state and `@MainActor` isolation are correct; builds with strict concurrency.
- [ ] Edge cases: theme overrides, zero/negative sizes, extreme values, tvOS (`#if !os(tvOS)` paths).
- [ ] Deprecated `iconFull` init still works and forwards new parameters.
- [ ] `swift build && swift test` run with real output.
