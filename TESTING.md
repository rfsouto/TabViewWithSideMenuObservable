# Pruebas

Probado con Xcode 27; el proyecto apunta a iOS 17.2.

## UI test automático

`MenuTabUITests` pulsa "Second", luego "Menu", y comprueba que el menú lateral se abre y que "Second" sigue
seleccionada. Desde Xcode: ⌘U. Desde terminal:

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
5. Compara las dos ramas. Con `@StateObject` el inicializador va en un autoclosure; con `@State` se evalúa en cada construcción de `ContentView()`.
