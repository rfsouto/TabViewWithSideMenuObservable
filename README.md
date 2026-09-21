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
| `main` | v2 más UI test, scripts de medición, resultados (`RESULTS.md`), README y TESTING. |
| `observable-migration` | Apunta al mismo commit que `v2-observable`. |
| `lazy-state-experiment` | `main` más `RootView` y un contador de inicializaciones del ViewModel (en pantalla y con `os.Logger`), con `@State`. |
| `lazy-state-classes` | `lazy-state-experiment` más dos sondas en `RootView`: `@State` con una clase `@Observable` y `@State` con una clase `ObservableObject`. |
| `measurements` | Rama donde se prepararon las mediciones (`scripts/`, `results/raw.tsv`, `RESULTS.md`); su punta ya está incluida en `main`. |
| `lazy-baseline-stateobject` | `v1-observableobject` más el mismo `RootView` y contador, con `@StateObject`. |
| `medicion-2026-09-21` | Tag sobre el último commit de `main` de esta tanda de mediciones (código, scripts, `RESULTS.md`, README y TESTING). |
| `exp-lazy-state-experiment`, `exp-lazy-baseline-stateobject`, `exp-lazy-state-classes` | Tags sobre la punta de cada rama de experimento cuando se hicieron las mediciones. |

## Cómo abrir el proyecto

1. `git checkout main` (o el tag o rama que quieras ver).
2. Abre `TabViewWithSideMenuWithViewModel.xcodeproj` en Xcode.
3. Elige un simulador de iPhone y pulsa Run (⌘R).

Los pasos de prueba manual y cómo lanzar los tests están en [TESTING.md](TESTING.md).

## Mediciones

Qué hay en el repo:

- [RESULTS.md](RESULTS.md): tablas finales (test del menú por runtime y variante del binding; inicializaciones del ViewModel por versión de Xcode), con la fecha y las versiones exactas de Xcode y Swift de cada medición.
- `results/raw.tsv`: los datos crudos, una fila por celda medida.
- `scripts/run_matrix.sh`: lanza una matriz de UI tests con `-destination id=<UDID>`, en un worktree temporal de la ref indicada (no commitea nada).
- `scripts/run_all.sh`: la lista exacta de mediciones que alimenta `RESULTS.md`.
- `scripts/make_results.py`: regenera `RESULTS.md` a partir de `results/raw.tsv`.

Para reproducirlas necesitas:

- macOS con Xcode 27 (y, para comparar toolchains, otras versiones instaladas, por ejemplo `/Applications/Xcode-26.2.0.app`).
- Los simuladores de los runtimes que quieras medir (`xcrun simctl list runtimes`).
- Ruby con el gem `xcodeproj` (`gem install xcodeproj`), python3 y git.

Cómo lanzar la matriz, desde la raíz del repo:

    # una celda o un grupo de runtimes
    scripts/run_matrix.sh binding --ref v2-observable --variant B --runtimes "17.2 27.0"

    # todas las mediciones (tarda decenas de minutos; las celdas que fallan en iOS 17.2 tardan unos 10 min extra)
    scripts/run_all.sh

    # regenerar las tablas
    python3 scripts/make_results.py > RESULTS.md

Los logs de cada celda se guardan en `results/logs/`, que git ignora.
