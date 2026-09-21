# Resultados de las mediciones

Generado con `scripts/make_results.py` a partir de `results/raw.tsv` (una fila por celda, con fecha, versiones y dispositivo).
Las mediciones las lanza `scripts/run_matrix.sh` (ver `scripts/run_all.sh` para la lista exacta) con `-destination id=<UDID>`; cada celda se ejecuta en un worktree temporal de la ref indicada, sin commitear nada. Si una celda se midió varias veces, aquí sale la última.

## Toolchains usadas

| Xcode | Swift | SDK | Fechas (primera – última medición) |
|---|---|---|---|
| Xcode 27.0 (27A266a) | Apple Swift version 6.4 (swiftlang-6.4.0.34.1 clang-2100.3.34.1) | iOS-27.0 | 2026-09-21T02:29:28+0200 – 2026-09-21T08:26:34+0200 |
| Xcode 26.2 (17C52) | Apple Swift version 6.2.3 (swiftlang-6.2.3.3.21 clang-1700.6.3.2) | iOS-26.2 | 2026-09-21T03:07:38+0200 – 2026-09-21T03:17:40+0200 |
| Xcode 26.0.1 (17A400) | Apple Swift version 6.2 (swiftlang-6.2.0.19.9 clang-1700.3.19.1) | iOS-26.0 | 2026-09-21T03:18:21+0200 – 2026-09-21T03:19:24+0200 |

## Binding: variantes A y B con el test reforzado (`MenuTabUITests`)

Cada celda es `pasa/iteraciones`. Variante A = `TabView(selection: Binding(get:set:))`; B = `TabView(selection: $viewModel.option)`. El test pulsa "Second", luego "Menu", y comprueba que el menú se abre, que "Second" sigue seleccionada y que el contenido visible es `content-second`.

**Xcode 27.0 (27A266a)**

| Ref | Variante | iOS 17.2 | iOS 18.1 | iOS 18.2 | iOS 18.3 | iOS 18.4 | iOS 18.5 | iOS 18.6 | iOS 26.2 | iOS 27.0 |
|---|---|---|---|---|---|---|---|---|---|---|
| `v1-observableobject` | A | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 |
| `v1-observableobject` | B | 0/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 |
| `v2-observable` | A | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 |
| `v2-observable` | B | 0/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 |

Mensajes de fallo exactos:

- `v1-observableobject` B iOS 17.2, `v2-observable` B iOS 17.2
  - `MenuTabUITests.swift:38: XCTAssertTrue failed - Tras pulsar Menu debe seguir seleccionada la pestaña anterior (Second); seleccionadas: ["Menu"], contenido visible: ["content-menu"]`

## Inicializaciones del ViewModel (`InitCountUITests` / `StateClassesUITests`)

Valores tras arrancar → tras 3 pulsaciones de "Incrementar". `RootView` construye `ContentView()` dentro de su `body`.

**Xcode 26.0.1 (17A400)**

| Ref | iOS 17.2 | iOS 18.6 | iOS 26.2 | iOS 27.0 |
|---|---|---|---|---|
| `lazy-state-experiment` | 1 → 4 | 1 → 4 | 1 → 4 | 1 → 4 |

**Xcode 26.2 (17C52)**

| Ref | iOS 17.2 | iOS 18.6 | iOS 26.2 | iOS 27.0 |
|---|---|---|---|---|
| `lazy-baseline-stateobject` | 1 → 1 | 1 → 1 | 1 → 1 | 1 → 1 |
| `lazy-state-classes` | VM 1→4 · sonda @Observable 1→4 · sonda ObservableObject 1→4 | VM 1→4 · sonda @Observable 1→4 · sonda ObservableObject 1→4 | VM 1→4 · sonda @Observable 1→4 · sonda ObservableObject 1→4 | VM 1→4 · sonda @Observable 1→4 · sonda ObservableObject 1→4 |
| `lazy-state-experiment` | 1 → 4 | 1 → 4 | 1 → 4 | 1 → 4 |

**Xcode 27.0 (27A266a)**

| Ref | iOS 17.2 | iOS 18.6 | iOS 26.2 | iOS 27.0 |
|---|---|---|---|---|
| `lazy-baseline-stateobject` | 1 → 1 | 1 → 1 | 1 → 1 | 1 → 1 |
| `lazy-state-classes` | VM 1→1 · sonda @Observable 1→1 · sonda ObservableObject 1→1 | VM 1→1 · sonda @Observable 1→1 · sonda ObservableObject 1→1 | VM 1→1 · sonda @Observable 1→1 · sonda ObservableObject 1→1 | VM 1→1 · sonda @Observable 1→1 · sonda ObservableObject 1→1 |
| `lazy-state-experiment` | 1 → 1 | 1 → 1 | 1 → 1 | 1 → 1 |

## Celdas repetidas con resultados distintos

Se muestra en las tablas la última medición; estas celdas dieron resultados diferentes entre repeticiones (test inestable):

- `lazy-state-experiment`  Xcode 27.0 (27A266a) iOS 27.0: pasa=0 falla=1 InitCountUITests.swift:22: XCTAssertTrue failed - La pulsación 1 no se registró; pasa=1 falla=0 27.0 launch=1 after3taps=1; pasa=1 falla=0 27.0 launch=1 after3taps=1

## Refs y commits medidos

- `v2-observable` = `2dc8276`
- `v1-observableobject` = `8d32e3d`
- `lazy-baseline-stateobject` = `ed95e23`
- `lazy-state-classes` = `3569f05`
- `lazy-state-experiment` = `3625582`
