#!/usr/bin/env bash
# Lista exacta de mediciones que alimentan RESULTS.md. Estar en la rama `measurements` (usa sus tests y scripts).
# Uso: scripts/run_all.sh [all|binding|inits]. Cada línea añade filas a results/raw.tsv. Después: python3 scripts/make_results.py > RESULTS.md
# Nota: en iOS 17.2 las celdas con fallo tardan ~10 min extra (xcodebuild espera tras acabar los tests).
set -u
cd "$(git rev-parse --show-toplevel)"
ONLY=${1:-all}   # all | binding | inits
m() { if [ "$ONLY" = all ] || [ "$ONLY" = "$1" ]; then scripts/run_matrix.sh "$@"; fi; }
X262=/Applications/Xcode-26.2.0.app
X2601=/Applications/Xcode-26.0.1.app

# --- Fase 1: lo pedido ---
# Frontera del Binding: variante B sobre v2 con el test reforzado
m binding --ref v2-observable --variant B --runtimes "18.1 18.2 18.3 18.4 18.5 17.2 27.0"
# Test reforzado sobre los tags: v1 B en 17.2 y 27.0; A en 17.2
m binding --ref v1-observableobject --variant B --runtimes "17.2 27.0"
m binding --ref v2-observable --variant A --runtimes "17.2"
m binding --ref v1-observableobject --variant A --runtimes "17.2"
# Con Xcode 26.2: @StateObject y sondas, en 17.2 y 27.0
m inits --ref lazy-baseline-stateobject --test InitCountUITests --xcode $X262 --runtimes "17.2 27.0"
m inits --ref lazy-state-classes --test StateClassesUITests --xcode $X262 --runtimes "17.2 27.0"

# --- Fase 2: completar las tablas ---
m binding --ref v2-observable --variant B --runtimes "18.6 26.2"
m binding --ref v1-observableobject --variant B --runtimes "18.1 18.2 18.3 18.4 18.5 18.6 26.2"
m binding --ref v2-observable --variant A --runtimes "18.1 18.2 18.3 18.4 18.5 18.6 26.2 27.0"
m binding --ref v1-observableobject --variant A --runtimes "18.1 18.2 18.3 18.4 18.5 18.6 26.2 27.0"
RT4="17.2 18.6 26.2 27.0"
m inits --ref lazy-state-experiment --test InitCountUITests --runtimes "$RT4"
m inits --ref lazy-baseline-stateobject --test InitCountUITests --runtimes "$RT4"
m inits --ref lazy-state-classes --test StateClassesUITests --runtimes "$RT4"
m inits --ref lazy-state-experiment --test InitCountUITests --xcode $X262 --runtimes "$RT4"
m inits --ref lazy-baseline-stateobject --test InitCountUITests --xcode $X262 --runtimes "18.6 26.2"
m inits --ref lazy-state-classes --test StateClassesUITests --xcode $X262 --runtimes "18.6 26.2"
m inits --ref lazy-state-experiment --test InitCountUITests --xcode $X2601 --runtimes "$RT4"
echo RUN_ALL_DONE
