"""Añade accessibilityIdentifier("content-<pestaña>") a cada Color de ContentView (idempotente).
Se ejecuta desde la raíz de un worktree; solo hace falta en refs que no los traen (v1, v2)."""
import re
p = 'TabViewWithSideMenuWithViewModel/Views/ContentView.swift'
s = open(p).read()
if 'content-first' not in s:
    for color, ident in [('Rojo', 'first'), ('Amarillo', 'second'), ('Azul', 'third'), ('Verde', 'menu')]:
        s, n = re.subn(r'(                Color\([^\n]*// %s\n)' % color,
                       r'\1                    .accessibilityIdentifier("content-%s")\n' % ident, s, count=1)
        assert n == 1, color
    open(p, 'w').write(s)
