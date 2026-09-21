"""Uso: pick_udid.py 18.3  ->  imprime "UDID<TAB>nombre<TAB>versión completa (build)" del primer iPhone Pro del runtime."""
import json, re, subprocess, sys
want = sys.argv[1]
major, minor = want.split('.')[:2]
key_end = 'iOS-%s-%s' % (major, minor)
runtimes = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'runtimes', '-j']))['runtimes']
info = {r['identifier']: r for r in runtimes}
devs = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'devices', 'available', '-j']))['devices']
for ident, lst in devs.items():
    if not ident.endswith(key_end):
        continue
    phones = [d for d in lst if d['name'].startswith('iPhone')]
    pro = [d for d in phones if re.match(r'^iPhone \d+ Pro$', d['name'])]
    pick = (pro or phones or [None])[0]
    if pick:
        r = info.get(ident, {})
        print('%s\t%s\t%s (%s)' % (pick['udid'], pick['name'], r.get('version', want), r.get('buildversion', '?')))
        sys.exit(0)
sys.exit(1)
