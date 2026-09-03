"""Captures Playwright du dossier (stack docker locale : front :3000, API :8000).
usage: backend/.venv/bin/python dossier/figures/captures/capture.py
Produit fig28, fig31, fig38, fig41 dans ce dossier."""
import html, json, sys, shutil
from pathlib import Path
from playwright.sync_api import sync_playwright

HERE = Path(__file__).parent
API, FRONT = "http://localhost:8000", "http://localhost:3000"
CHROME = shutil.which("chromium") or shutil.which("google-chrome")

def response_page(method, url, resp):
    """Rend une réponse HTTP brute (statut, en-têtes, JSON) dans une page neutre."""
    try: body = json.dumps(resp.json(), indent=2, ensure_ascii=False)
    except Exception: body = resp.text()
    hdrs = "\n".join(f"{k}: {v}" for k, v in resp.headers.items() if k.lower() in ("content-type", "x-request-id", "date", "server", "www-authenticate"))
    ok = 200 <= resp.status < 300
    return f"""<!doctype html><meta charset=utf-8><style>
body{{margin:0;padding:28px 40px 32px;width:900px;box-sizing:border-box;font:14px/1.5 'JetBrains Mono','DejaVu Sans Mono',monospace;background:#fff;color:#111}}
.req{{font-size:16px;font-weight:600;margin-bottom:6px}} .req span{{color:#2563eb}}
.st{{display:inline-block;padding:2px 10px;border-radius:6px;font-weight:600;margin-bottom:14px;color:#fff;background:{'#16a34a' if ok else '#dc2626'}}}
.h{{color:#666;white-space:pre;margin-bottom:14px;padding-bottom:12px;border-bottom:1px solid #e5e7eb}}
pre{{margin:0;white-space:pre-wrap;word-break:break-word}}</style>
<div class=req><span>{method}</span> {html.escape(url)}</div>
<div class=st>HTTP {resp.status} {html.escape(resp.status_text or '')}</div>
<div class=h>{html.escape(hdrs)}</div><pre>{html.escape(body)}</pre>"""

with sync_playwright() as p:
    b = p.chromium.launch(executable_path=CHROME)
    ctx = b.new_context(viewport={"width": 1440, "height": 900}, device_scale_factor=2, locale="fr-FR")
    pg = ctx.new_page()

    # jeton utilisateur simple (rôle USER) pour 31 et 41
    r = ctx.request.post(f"{API}/api/auth/login", data={"identifiant": "user", "mot_de_passe": "user"})
    assert r.ok, r.text()
    tok = r.json()["data"]["access_token"]
    auth = {"Authorization": f"Bearer {tok}"}

    # fig38 — GET /health tel que rendu par le navigateur
    resp = ctx.request.get(f"{API}/health"); assert resp.ok
    pg.set_content(response_page("GET", f"{API}/health", resp)); pg.wait_for_timeout(200)
    pg.locator("body").screenshot(path=HERE / "fig38_health.png")

    # fig31 — 403 sur une route admin avec le compte user
    url = f"{API}/api/admin/utilisateurs"
    resp = ctx.request.get(url, headers=auth); assert resp.status == 403, resp.status
    pg.set_content(response_page("GET", url, resp)); pg.wait_for_timeout(200)
    pg.locator("body").screenshot(path=HERE / "fig31_admin_403.png")

    # fig41 — journal des appels IA
    url = f"{API}/api/ai/ai-calls/history"
    resp = ctx.request.get(url, headers=auth); assert resp.ok and resp.json()["data"], "journal IA vide"
    pg.set_content(response_page("GET", url, resp)); pg.wait_for_timeout(200)
    pg.locator("body").screenshot(path=HERE / "fig41_journal_appels_ia.png")

    # fig28 — page admin des contrôles qualité (contexte neuf, connexion par le formulaire)
    ctx2 = b.new_context(viewport={"width": 1440, "height": 900}, device_scale_factor=2, locale="fr-FR")
    pg = ctx2.new_page()
    pg.goto(f"{FRONT}/login"); pg.wait_for_selector("form")
    pg.get_by_label("Identifiant").fill("admin")
    pg.get_by_label("Mot de passe").fill("admin")
    pg.locator("form button[type=submit]").click()
    pg.wait_for_url(lambda u: "/login" not in u, timeout=20000)
    pg.goto(f"{FRONT}/admin/controles-qualite")
    pg.wait_for_selector("table, [role=table]", timeout=20000); pg.wait_for_timeout(1200)
    pg.screenshot(path=HERE / "fig28_admin_controles_qualite.png", full_page=True)
    print("url finale fig28:", pg.url)
    b.close()
for f in sorted(HERE.glob("fig*.png")): print(f.name, f.stat().st_size)
