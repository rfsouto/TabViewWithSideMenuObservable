#!/usr/bin/env bash
# Ejecuta una matriz de UI tests en simuladores concretos (-destination id=<UDID>) sobre un worktree temporal
# de una ref de git (sin commitear nada) y añade una fila por celda a results/raw.tsv.
#
# Uso:
#   scripts/run_matrix.sh binding --ref v2-observable --variant B --runtimes "17.2 18.1 27.0" [--iterations 3]
#   scripts/run_matrix.sh inits   --ref lazy-state-classes --test StateClassesUITests --runtimes "17.2 27.0"
# Opciones comunes: --xcode /Applications/Xcode-26.2.0.app (por defecto /Applications/Xcode.app)
# Requisitos: Xcode, ruby con el gem xcodeproj, python3 y los runtimes de simulador instalados.
#
# binding: copia MenuTabUITests.swift de esta rama, añade el target de UI tests si la ref no lo tiene,
#          inyecta los accessibilityIdentifier de los colores y, con --variant B, sustituye el Binding manual
#          por TabView(selection: $viewModel.option).
# inits:   usa los tests que ya trae la ref (InitCountUITests o StateClassesUITests).
set -u
ROOT=$(git rev-parse --show-toplevel); cd "$ROOT"
SCRIPTS="$ROOT/scripts"
MODE=${1:?modo: binding|inits}; shift
REF=; RUNTIMES=; VARIANT=A; ITER=""; XCODE=/Applications/Xcode.app; TEST=InitCountUITests
while [ $# -gt 0 ]; do
  case $1 in
    --ref) REF=$2;; --runtimes) RUNTIMES=$2;; --variant) VARIANT=$2;; --iterations) ITER=$2;;
    --xcode) XCODE=$2;; --test) TEST=$2;;
    *) echo "argumento desconocido: $1" >&2; exit 2;;
  esac; shift 2
done
[ -n "$REF" ] && [ -n "$RUNTIMES" ] || { echo "faltan --ref y --runtimes" >&2; exit 2; }
[ -n "$ITER" ] || { [ "$MODE" = binding ] && ITER=3 || ITER=1; }
export DEVELOPER_DIR="$XCODE/Contents/Developer"

TSV=${RESULTS_TSV:-$ROOT/results/raw.tsv}; LOGS=${LOGS_DIR:-$ROOT/results/logs}
mkdir -p "$(dirname "$TSV")" "$LOGS"
[ -f "$TSV" ] || printf 'fecha\tmodo\tref\tsha\tvariante\txcode\tswift\tsdk\truntime\tdispositivo\titeraciones\tpasa\tfalla\tdetalle\n' > "$TSV"
XVER=$(xcodebuild -version | tr '\n' ' ' | sed 's/ *$//')
SWIFTV=$(xcrun swiftc --version 2>&1 | head -1)
SDKV=iOS-$(xcrun --sdk iphonesimulator --show-sdk-version)
SHA=$(git rev-parse --short "$REF")
XTAG=$(basename "$XCODE" .app)

WT=$(mktemp -d "${TMPDIR:-/tmp}/matrix.XXXXXX")
cleanup() { git -C "$ROOT" worktree remove --force "$WT/src" >/dev/null 2>&1; rm -rf "$WT"; }
trap cleanup EXIT
git worktree add -q --detach "$WT/src" "$REF" || exit 1
cd "$WT/src"
UIDIR=TabViewWithSideMenuWithViewModelUITests
mkdir -p $UIDIR
if [ "$MODE" = binding ]; then
  cp "$ROOT/$UIDIR/MenuTabUITests.swift" $UIDIR/
  python3 "$SCRIPTS/add_identifiers.py" || exit 1
  [ "$VARIANT" = B ] && { python3 "$SCRIPTS/variant_b.py" || exit 1; }
  ONLY=MenuTabUITests
else
  ONLY=$TEST; VARIANT=-
fi
ruby "$SCRIPTS/add_uitests.rb" $(cd $UIDIR && ls *.swift) 2>&1 | grep -v "warning:\|Ignoring"

for RT in $RUNTIMES; do
  if ! IFS=$'\t' read -r UDID DEV RTFULL < <(python3 "$SCRIPTS/pick_udid.py" "$RT"); then
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t-\t%s\t0\t0\t%s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$MODE" "$REF" "$SHA" "$VARIANT" "$XVER" "$SWIFTV" "$SDKV" "$RT" "$ITER" "sin simulador iPhone para este runtime" >> "$TSV"
    continue
  fi
  LOG="$LOGS/$MODE-$REF-$VARIANT-$XTAG-$RT.log"; RES="$WT/result.txt"; rm -f "$RES"
  TEST_RUNNER_RESULT_FILE="$RES" xcodebuild -project TabViewWithSideMenuWithViewModel.xcodeproj \
    -scheme TabViewWithSideMenuWithViewModel -destination "id=$UDID" -derivedDataPath "$WT/dd" \
    -only-testing:$UIDIR/$ONLY -test-iterations "$ITER" test > "$LOG" 2>&1
  EXIT=$?
  PASS=$(grep -c "^Test Case .* passed" "$LOG"); FAIL=$(grep -c "^Test Case .* failed" "$LOG")
  DETAIL=""
  [ -f "$RES" ] && DETAIL=$(paste -sd'|' "$RES")
  ERRS=$(grep -h ": error: " "$LOG" | sed -E 's#^.*/([A-Za-z]+\.swift:[0-9]+): error: -\[[^]]*\] : #\1: #; s#^/.*/([A-Za-z]+\.swift:[0-9]+:[0-9]+: error)#\1#' | sort -u | head -3 | paste -sd'|' -)
  [ -n "$ERRS" ] && DETAIL="${DETAIL:+$DETAIL | }$ERRS"
  [ "$EXIT" != 0 ] && [ "$PASS" = 0 ] && [ "$FAIL" = 0 ] && DETAIL="xcodebuild exit=$EXIT sin casos de test; ${DETAIL}"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s (%s)\t%s\t%s\t%s\t%s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$MODE" "$REF" "$SHA" "$VARIANT" "$XVER" "$SWIFTV" "$SDKV" "$RTFULL" "$DEV" "$UDID" "$ITER" "$PASS" "$FAIL" "$DETAIL" >> "$TSV"
  echo "$MODE $REF $VARIANT $XTAG iOS $RT: pasa=$PASS falla=$FAIL ${DETAIL}"
done
