# Pruebas

Probado con Xcode 27; el proyecto apunta a iOS 17.2.

## UI test automático

`MenuTabUITests` pulsa "Second", luego "Menu", y comprueba que el menú lateral se abre, que "Second" sigue
seleccionada y que el contenido visible es el de esa pestaña (`content-second`; cada color tiene su `accessibilityIdentifier`). Desde Xcode: ⌘U. Desde terminal:

    xcodebuild -project TabViewWithSideMenuWithViewModel.xcodeproj \
      -scheme TabViewWithSideMenuWithViewModel \
      -destination 'id=<UDID de un simulador>' test

Ejecuta el mismo test con la variante A (por defecto) y con la B (ver abajo).

## Manual: variantes del binding del TabView

En `ContentView.swift`:
- **Variante A** (por defecto): `TabView(selection: Binding(get:set:))`.
- **Variante B**: comenta el bloque de la A y descomenta `TabView(selection: $viewModel.option) {`.

Para cada variante:
1. Arranca la app: debe verse "First" (roja).
2. Pulsa "Second" y luego "Third": cambia el color.
3. Pulsa "Menu". Esperado: se abre el menú lateral y la pestaña seleccionada vuelve a la anterior (Third), sin quedarse en "Menu" (verde).
4. Cierra el menú tocando fuera y repite desde otra pestaña.

Si en la variante B el menú no se abre o la pestaña se queda en "Menu", anótalo: es lo que se compara.

## Contar inicializaciones del ViewModel (ramas del experimento)

Ramas: `lazy-state-experiment` (`@State`) y `lazy-baseline-stateobject` (`@StateObject`).

1. `git checkout` de la rama y ejecuta con ⌘R.
2. Sobre el botón "Incrementar (N)" aparece `inits: K`, el número de veces que se ha construido `ContentViewModel`. El valor se refresca unas 4 veces por segundo.
3. Anota K tras arrancar. Pulsa "Incrementar" 3 veces y anota K otra vez.
4. Comprobación cruzada en la consola de Xcode (⇧⌘C): filtra por `ContentViewModel init`. Cada línea lleva su número, emitida con `os.Logger` (categoría `experiment`).
5. Compara las dos ramas.

### Resultados medidos (UI test `InitCountUITests`, rama `lazy-state-experiment`)

Valores `inits` tras arrancar → tras 3 pulsaciones de "Incrementar". El resultado depende de la toolchain con la que se compila, no del runtime en el que se ejecuta:

| Compilado con | Ejecutado en iOS 17.2 / 18.6 / 26.2 / 27.0 |
|---|---|
| Xcode 27.0 (Swift 6.4, SDK 27.0) | 1 → 1 en los cuatro |
| Xcode 26.2 (Swift 6.2, SDK 26.2) | 1 → 4 en los cuatro |
| Xcode 26.0.1 (Swift 6.2, SDK 26.0) | 1 → 4 en los cuatro |

Con Xcode 26.x, `@State private var viewModel = ContentViewModel()` construye un ViewModel nuevo en cada `ContentView()` (aunque SwiftUI conserve el primero). Con Xcode 27 no. No he verificado la causa; la interfaz de `State.init(wrappedValue:)` es la misma en los tres SDK (sin autoclosure).

Con Xcode 27, `lazy-baseline-stateobject` (`@StateObject`) da 1 → 1 en los cuatro runtimes. Con Xcode 26.x no se ha medido esa rama.
Con Xcode 27, la rama `lazy-state-classes` (`@State` con una clase `@Observable` y con una `ObservableObject`) da 1 → 1 para ambas en iOS 17.2 y 27.0.
Control positivo (Xcode 27): si `RootView` construye a propósito un `ContentViewModel` extra en cada `body`, el contador da 2 → 5, así que la medición detecta las reconstrucciones.

## Matriz del binding (UI test `MenuTabUITests`)

3 ejecuciones por celda, Xcode 27.0, simuladores iPhone. Variante A = Binding manual; B = `$viewModel.option`.

| Versión | Variante | 17.2 | 18.6 | 26.2 | 27.0 |
|---|---|---|---|---|---|
| `v1-observableobject` | A | 3/3 | 3/3 | 3/3 | 3/3 |
| `v1-observableobject` | B | 0/3 | 3/3 | 3/3 | 3/3 |
| `v2-observable` | A | 3/3 | 3/3 | 3/3 | 3/3 |
| `v2-observable` | B | 0/3 | 3/3 | 3/3 | 3/3 |

Las celdas de v1 y v2 se midieron con la primera versión del test (solo comprueba la selección). Con el test actual, sobre `main`, A pasa 3/3 en los cuatro runtimes y B pasa 3/3 en 18.6, 26.2 y 27.0.
Fallo de la variante B en iOS 17.2 (las 3 veces): el menú se abre, pero la pestaña "Menu" queda seleccionada y se ve `content-menu`:

    MenuTabUITests.swift:38: error: ... XCTAssertTrue failed - Tras pulsar Menu debe seguir seleccionada la pestaña anterior (Second); seleccionadas: ["Menu"], contenido visible: ["content-menu"]
