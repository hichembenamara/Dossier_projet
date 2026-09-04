#!/usr/bin/env bash
# usage: build.sh <type> <name>   — <name>.<type>.json dans ce dossier → <name>.html + <name>.png
# Dépendances : archify (ARCHIFY_HOME, défaut ~/tools/archify/archify), chromium headless.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
ARCHIFY_HOME="${ARCHIFY_HOME:-$HOME/tools/archify/archify}"
CHROME="${ARCHIFY_CHROME:-$(command -v chromium || command -v google-chrome || echo /opt/google/chrome/chrome)}"
export ARCHIFY_CHROME="$CHROME"
T=$1; N=$2; IN="$HERE/$N.$T.json"; OUT="$HERE/$N.html"
# Preuves de code (champ sources) : --repo-root n'existe que pour le type architecture
REPO_OPT=""; [ "$T" = "architecture" ] && REPO_OPT="--repo-root ${ARCHIFY_REPO_ROOT:-$(cd "$HERE/../../.." && pwd)}"
cd "$ARCHIFY_HOME"
node bin/archify.mjs validate "$T" "$IN" --quality showcase $REPO_OPT --json | python3 -c "
import sys,json;d=json.load(sys.stdin);ok=d.get('ok');print('validate ok' if ok else 'VALIDATE FAIL')
for x in d.get('diagnostics',[]): print(' -',x.get('severity'),x.get('code'),x.get('message','')[:300]); print('   fixes:',x.get('supportedFixes'))
sys.exit(0 if ok else 1)"
node bin/archify.mjs deliver "$T" "$IN" "$OUT" --quality showcase $REPO_OPT --json | python3 -c "import sys,json;d=json.load(sys.stdin);print('deliver ok' if d.get('ok') else 'DELIVER FAIL');sys.exit(0 if d.get('ok') else 1)"
node bin/archify.mjs visual-check "$OUT" --json | python3 -c "import sys,json;d=json.load(sys.stdin);print('visual-check',d.get('status')); [print(' -',x['severity'],x['message'][:160]) for x in d.get('diagnostics',[]) if x['severity']=='error']"
# PNG du seul diagramme (SVG) pour l'impression : thème clair, échelle 2x, fond blanc
PY="${ARCHIFY_PY:-$HERE/../../../backend/.venv/bin/python}"
"$PY" - "$OUT" "$HERE/$N.png" "$CHROME" <<'PY'
import sys
from playwright.sync_api import sync_playwright
html, png, chrome = sys.argv[1:4]
with sync_playwright() as p:
    b = p.chromium.launch(executable_path=chrome)
    pg = b.new_page(viewport={"width": 1600, "height": 1000}, device_scale_factor=2)
    pg.goto("file://" + html + "?theme=light")
    pg.wait_for_timeout(800)
    pg.query_selector("svg").screenshot(path=png)
    b.close()
print("png", png)
PY
