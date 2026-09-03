#!/usr/bin/env bash
# usage: build.sh <type> <name>   (name.<type>.json in /home/claude/figs)
set -e
export ARCHIFY_CHROME=/opt/pw-browsers/chromium-1194/chrome-linux/chrome
cd /home/claude/archify/archify
T=$1; N=$2; IN=/home/claude/figs/$N.$T.json; OUT=/home/claude/figs/$N.html
node bin/archify.mjs validate $T $IN --quality showcase --json | python3 -c "import sys,json;d=json.load(sys.stdin);print('validate ok' if d.get('ok') else 'VALIDATE FAIL'); [print(' -',x['severity'],x['message'][:220]) for x in d.get('diagnostics',[])]"
node bin/archify.mjs deliver $T $IN $OUT --quality showcase --json | python3 -c "import sys,json;d=json.load(sys.stdin);print('deliver ok' if d.get('ok') else 'DELIVER FAIL')"
node bin/archify.mjs visual-check $OUT --json | python3 -c "import sys,json;d=json.load(sys.stdin);print('visual-check',d.get('status')); [print(' -',x['severity'],x['message'][:160]) for x in d.get('diagnostics',[]) if x['severity']=='error']"
# full-resolution PNG of the diagram for print (light theme, 2x)
python3 - "$OUT" "/home/claude/figs/$N.png" <<'PY'
import sys
from playwright.sync_api import sync_playwright
html,png=sys.argv[1],sys.argv[2]
with sync_playwright() as p:
    b=p.chromium.launch(); pg=b.new_page(viewport={'width':1600,'height':1000},device_scale_factor=2)
    pg.goto('file://'+html); pg.wait_for_timeout(800)
    el=pg.query_selector('svg')
    el.screenshot(path=png)
    b.close()
print('png',png)
PY
