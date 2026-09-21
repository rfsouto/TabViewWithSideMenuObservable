# Pruebas

Probado con Xcode 27; el proyecto apunta a iOS 17.2.

## UI test automático

`MenuTabUITests` pulsa "Second", luego "Menu", y comprueba tres cosas:

1. el menú lateral se abre;
2. la pestaña seleccionada sigue siendo "Second";
3. el contenido visible es el de esa pestaña (`content-second`; cada color tiene su `accessibilityIdentifier`).

Desde Xcode: ⌘U. Desde terminal:

    xcodebuild -project TabViewWithSideMenuWithViewModel.xcodeproj \
      -scheme TabViewWithSideMenuWithViewModel \
      -destination 'id=<UDID de un simulador>' test

Ejecuta el mismo test con la variante A (por defecto) y con la B (ver abajo).

## Matrices de pruebas

Las matrices (versión o rama × variante × runtime × versión de Xcode) se ejecutan con `scripts/run_matrix.sh`,
con `-destination id=<UDID>`. Cada celda se ejecuta en un worktree temporal de la ref indicada, sin commitear nada,
y añade una fila a `results/raw.tsv`. Ejemplos:

    # Test del menú (variante B) sobre el tag v2, en dos runtimes, 3 ejecuciones por celda
    scripts/run_matrix.sh binding --ref v2-observable --variant B --runtimes "17.2 27.0" --iterations 3

    # Inicializaciones del ViewModel en una rama del experimento, con otra versión de Xcode
    scripts/run_matrix.sh inits --ref lazy-state-classes --test StateClassesUITests \
      --xcode /Applications/Xcode-26.2.0.app --runtimes "17.2 27.0"

`scripts/run_all.sh` contiene la lista exacta de mediciones, y `python3 scripts/make_results.py > RESULTS.md`
regenera las tablas a partir de `results/raw.tsv`.

Las tablas finales, con la fecha y las versiones exactas de Xcode y Swift de cada medición, están en
[RESULTS.md](RESULTS.md). No se copian resultados en este documento. Requisitos para reproducirlas: ver el README.

## Manual: variantes del binding del TabView

En `ContentView.swift`:
- **Variante A** (por defecto): `TabView(selection: Binding(get:set:))`.
- **Variante B**: comenta el bloque de la A y descomenta `TabView(selection: $viewModel.option) {`.

Para cada variante:
1. Arranca la app: debe verse "First" (roja).
2. Pulsa "Second" y luego "Third": cambia el color.
3. Pulsa "Menu". Esperado: se abre el menú lateral y la pestaña seleccionada vuelve a la anterior (Third), sin quedarse en "Menu" (verde).
4. Cierra el menú tocando fuera de él y repite desde otra pestaña.

Si en alguna variante el menú no se abre o la pestaña se queda en "Menu", anótalo: es lo que se compara. Los resultados medidos por runtime están en `RESULTS.md`.

## Contar inicializaciones del ViewModel (ramas del experimento)

Ramas: `lazy-state-experiment` (`@State`), `lazy-baseline-stateobject` (`@StateObject`) y `lazy-state-classes`
(`@State` con una clase `@Observable` y con una clase `ObservableObject`).

1. `git checkout` de la rama y ejecuta con ⌘R.
2. Sobre el botón "Incrementar (N)" aparece `inits: K`, el número de veces que se ha construido `ContentViewModel`. El valor se refresca unas 4 veces por segundo. En `lazy-state-classes` aparecen además `obs: N` y `obj: M`, los de las dos sondas.
3. Anota K tras arrancar. Pulsa "Incrementar" 3 veces y anota K otra vez.
4. Comprobación cruzada en la consola de Xcode (⇧⌘C): filtra por `ContentViewModel init`. Cada línea lleva su número, emitida con `os.Logger` (categoría `experiment`).
5. Compara las ramas. El resultado puede depender de la versión de Xcode con la que compiles: repite con cada toolchain que quieras comparar (ver `RESULTS.md`).
