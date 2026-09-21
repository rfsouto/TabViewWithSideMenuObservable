"""Genera RESULTS.md a partir de results/raw.tsv (se queda con la última fila de cada celda).
Uso: python3 scripts/make_results.py > RESULTS.md"""
import csv, re, collections

rows = list(csv.DictReader(open('results/raw.tsv'), delimiter='\t'))

def latest(rs, key):
    d = {}
    for r in rs:
        d[key(r)] = r  # el fichero está en orden cronológico
    return d

def rt_key(r):  # "18.3.1 (22D8075)" -> "18.3"
    m = re.match(r'(\d+)\.(\d+)', r['runtime'])
    return '%s.%s' % m.groups() if m else r['runtime']

def xcode_short(r):
    m = re.match(r'Xcode (\S+) Build version (\S+)', r['xcode'])
    return 'Xcode %s (%s)' % m.groups() if m else r['xcode']

def rt_sort(v):
    return tuple(int(x) for x in v.split('.'))

out = []
p = out.append
p('# Resultados de las mediciones\n')
p('Generado con `scripts/make_results.py` a partir de `results/raw.tsv` (una fila por celda, con fecha, versiones y dispositivo).')
p('Las mediciones las lanza `scripts/run_matrix.sh` (ver `scripts/run_all.sh` para la lista exacta) con `-destination id=<UDID>`; '
  'cada celda se ejecuta en un worktree temporal de la ref indicada, sin commitear nada. Si una celda se midió varias veces, aquí sale la última.\n')

# Toolchains
tool = collections.OrderedDict()
for r in rows:
    tool.setdefault((xcode_short(r), r['swift'], r['sdk']), []).append(r['fecha'])
p('## Toolchains usadas\n')
p('| Xcode | Swift | SDK | Fechas (primera – última medición) |')
p('|---|---|---|---|')
for (x, sw, sdk), fs in tool.items():
    p('| %s | %s | %s | %s – %s |' % (x, sw, sdk, min(fs), max(fs)))
p('')

# Binding
b = latest([r for r in rows if r['modo'] == 'binding'],
           lambda r: (r['ref'], r['variante'], xcode_short(r), rt_key(r)))
if b:
    p('## Binding: variantes A y B con el test reforzado (`MenuTabUITests`)\n')
    p('Cada celda es `pasa/iteraciones`. Variante A = `TabView(selection: Binding(get:set:))`; B = `TabView(selection: $viewModel.option)`. '
      'El test pulsa "Second", luego "Menu", y comprueba que el menú se abre, que "Second" sigue seleccionada y que el contenido visible es `content-second`.\n')
    for xc in sorted({k[2] for k in b}):
        rts = sorted({k[3] for k in b if k[2] == xc}, key=rt_sort)
        p('**%s**\n' % xc)
        p('| Ref | Variante | ' + ' | '.join('iOS ' + t for t in rts) + ' |')
        p('|---|---|' + '---|' * len(rts))
        for ref, var in sorted({(k[0], k[1]) for k in b if k[2] == xc}):
            cells = []
            for t in rts:
                r = b.get((ref, var, xc, t))
                cells.append('—' if not r else '%s/%s' % (r['pasa'], r['iteraciones']))
            p('| `%s` | %s | ' % (ref, var) + ' | '.join(cells) + ' |')
        p('')
    fails = collections.OrderedDict()
    for k, r in b.items():
        if int(r['falla']) or int(r['pasa']) == 0:
            fails.setdefault(r['detalle'], []).append('`%s` %s iOS %s' % (k[0], k[1], k[3]))
    if fails:
        p('Mensajes de fallo exactos:\n')
        for msg, where in fails.items():
            p('- %s\n  - `%s`' % (', '.join(sorted(where)), msg))
        p('')

# Inits
i = latest([r for r in rows if r['modo'] == 'inits'], lambda r: (r['ref'], xcode_short(r), rt_key(r)))
if i:
    p('## Inicializaciones del ViewModel (`InitCountUITests` / `StateClassesUITests`)\n')
    p('Valores tras arrancar → tras 3 pulsaciones de "Incrementar". `RootView` construye `ContentView()` dentro de su `body`.\n')
    def parse(d):
        m = re.search(r'launch=(\d+) after3taps=(\d+)', d)
        if m:
            return '%s → %s' % m.groups()
        m = re.search(r'contentVM=(-?\d+)->(-?\d+) observableProbe=(-?\d+)->(-?\d+) objectProbe=(-?\d+)->(-?\d+)', d)
        if m:
            g = m.groups()
            return 'VM %s→%s · sonda @Observable %s→%s · sonda ObservableObject %s→%s' % g
        return '¿? ' + d[:80]
    for xc in sorted({k[1] for k in i}):
        rts = sorted({k[2] for k in i if k[1] == xc}, key=rt_sort)
        p('**%s**\n' % xc)
        p('| Ref | ' + ' | '.join('iOS ' + t for t in rts) + ' |')
        p('|---|' + '---|' * len(rts))
        for ref in sorted({k[0] for k in i if k[1] == xc}):
            cells = []
            for t in rts:
                r = i.get((ref, xc, t))
                cells.append('—' if not r else (parse(r['detalle']) if int(r['pasa']) else 'falla: ' + r['detalle'][:80]))
            p('| `%s` | ' % ref + ' | '.join(cells) + ' |')
        p('')

p('## Refs y commits medidos\n')
refs = collections.OrderedDict()
for r in rows:
    refs[(r['ref'], r['sha'])] = 1
for ref, sha in refs:
    p('- `%s` = `%s`' % (ref, sha))
print('\n'.join(out))
