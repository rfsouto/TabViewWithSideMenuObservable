# TabView con menú lateral: de ObservableObject a @Observable

Ejemplo SwiftUI (TabView + SlideMenu + `ContentViewModel`) usado para ilustrar la migración de
`ObservableObject`/`@Published`/`@StateObject` al macro `@Observable` con `@State`.

## Requisitos

- Probado con Xcode 27.
- El proyecto apunta a iOS 17.2 (`IPHONEOS_DEPLOYMENT_TARGET = 17.2`); `@Observable` exige iOS 17 o superior.

## Versiones (tags y ramas)

| Referencia | Contenido |
|---|---|
| `v1-observableobject` | Original: `ObservableObject`, `@Published` y `@StateObject var viewModel: ContentViewModel = ContentViewModel()`. |
| `v2-observable` | Migrada a `@Observable` y `@State private var viewModel = ContentViewModel()`. El diff v1→v2 es justo esa migración. |
| `main` | v2 más UI test, README y TESTING. |
| `observable-migration` | Apunta al mismo commit que `v2-observable`. |
| `lazy-state-experiment` | `main` más `RootView` y un contador de inicializaciones del ViewModel (en pantalla y con `os.Logger`), con `@State`. |
| `lazy-state-classes` | `lazy-state-experiment` más dos sondas en `RootView`: `@State` con una clase `@Observable` y `@State` con una clase `ObservableObject`. |
| `measurements` | `main` más `scripts/` (`run_matrix.sh`, `run_all.sh`, `make_results.py`), `results/raw.tsv` y `RESULTS.md` con las mediciones reproducibles. |
| `lazy-baseline-stateobject` | `v1-observableobject` más el mismo `RootView` y contador, con `@StateObject`. |

## Cómo abrir el proyecto

1. `git checkout main` (o el tag o rama que quieras ver).
2. Abre `TabViewWithSideMenuWithViewModel.xcodeproj` en Xcode.
3. Elige un simulador de iPhone y pulsa Run (⌘R).

Los pasos de prueba manual y cómo lanzar los tests están en [TESTING.md](TESTING.md).
