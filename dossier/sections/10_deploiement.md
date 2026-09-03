# X. Déploiement et démarche DevOps

## 1. Documentation de déploiement

### Procédure d'installation

La procédure complète est dans `README.md` et `docs/MAINTENANCE.md`. Elle tient en six étapes et a été chronométrée sous les trente minutes exigées par le cahier des charges de la première MSPR sur une machine où Docker est déjà installé.

1. Cloner le dépôt et se placer sur la branche `maintenance`.
2. Copier `.env.example` en `.env`. Les valeurs par défaut suffisent pour une démonstration ; renseigner `GEMINI_API_KEY` pour activer l'analyse de repas et `OLLAMA_BASE_URL` si Ollama tourne sur une autre machine.
3. `make up` : construit les images et démarre `db`, `mongo`, `backend`, `frontend`. Le frontend attend que l'API soit `healthy`.
4. `docker compose --profile etl run --rm etl` : charge les jeux de données et crée les comptes de démonstration.
5. Vérifier `http://localhost:8000/health` et ouvrir `http://localhost:3000` avec un compte de démonstration.
6. `make monitoring-up` pour ajouter Prometheus et Grafana.

*Figure 37 — Services, URL et ports (tableau Word).*

| Service | URL | Remarque |
|---|---|---|
| Frontend | http://localhost:3000 | |
| API | http://localhost:8000/api | |
| Documentation OpenAPI | http://localhost:8000/api/docs | ReDoc sur `/api/redoc` |
| État de santé | http://localhost:8000/health | statut des deux bases |
| Métriques | http://localhost:8000/metrics | format Prometheus |
| MariaDB | 127.0.0.1:3307 | accès local uniquement |
| MongoDB | 127.0.0.1:27017 | accès local uniquement |
| Prometheus | http://127.0.0.1:9090 | accès local uniquement |
| Grafana | http://127.0.0.1:3001 | accès local uniquement |

*Figure 38 — Réponse de `GET /health` avec les deux bases disponibles (capture Playwright, `dossier/figures/captures/fig38_health.png`).*

```json
{"data": {"status": "ok", "databases": {"relationnel": "mariadb", "documentaire": "ok"}}}
```

### Commandes d'exploitation

**Extrait 26 — `Makefile`**

```makefile
up:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

reset:
	$(COMPOSE) down -v
	$(COMPOSE) up -d --build

logs:
	$(COMPOSE) logs -f --tail=100

test:
	cd backend && python -m pytest -q

backup:
	bash scripts/backup.sh

restore:
	bash scripts/restore.sh $(DIR)

monitoring-up:
	$(COMPOSE) $(MONITORING) up -d --build
```

Pourquoi ce choix : un exploitant qui reprend le projet n'a pas à connaître les options de Docker Compose ni le nom des fichiers de configuration ; `make help` liste les commandes, chacune fait une seule chose. La cible `reset` supprime les volumes : elle est documentée comme destructive et n'a pas de raccourci plus court.

### Sauvegarde et restauration

**Extrait 27 — `scripts/backup.sh`**

```bash
#!/usr/bin/env bash
# Sauvegarde des bases HealthAI Coach (MariaDB + MongoDB) depuis les conteneurs Docker.
set -euo pipefail
cd "$(dirname "$0")/.."

DB_CONTAINER="${DB_CONTAINER:-healthai-db}"
MONGO_CONTAINER="${MONGO_CONTAINER:-healthai-mongo}"
DB_NAME="${DB_NAME:-healthai_coaching}"
MONGO_DB="${MONGO_DB_NAME:-healthai_nosql}"

TS="$(date +%Y%m%d_%H%M%S)"
OUT="backups/$TS"
mkdir -p "$OUT"

docker exec "$DB_CONTAINER" mariadb-dump -uroot -p"$DB_ROOT_PASSWORD" \
  --single-transaction --routines --triggers "$DB_NAME" > "$OUT/mariadb_${DB_NAME}.sql"

docker exec "$MONGO_CONTAINER" mongodump --quiet --db "$MONGO_DB" --archive > "$OUT/mongo_${MONGO_DB}.archive"

echo "==> Sauvegarde terminée : $OUT"
```

Pourquoi ce choix : `--single-transaction` produit un instantané cohérent d'InnoDB sans verrouiller les tables, donc l'application reste utilisable pendant la sauvegarde. Les deux bases sont sauvegardées dans le même répertoire horodaté : une restauration ramène l'ensemble à un instant unique, ce qui évite qu'une recommandation dans MongoDB pointe vers un utilisateur qui n'existe plus dans MariaDB. `set -euo pipefail` arrête le script à la première erreur au lieu de produire une sauvegarde partielle. `restore.sh` fait l'inverse à partir d'un répertoire donné (`make restore DIR=backups/20260702_1200`). Le script a été testé sous Linux, macOS et Git Bash sous Windows.

Ce qui n'est pas fait, et qui serait la première étape en production : planifier la sauvegarde (cron ou service Compose dédié) et la copier hors de la machine.

## 2. Intégration continue

*Figure 39 — Pipeline d'intégration continue (archify, `dossier/figures/archify/fig39_pipeline_ci.png`).*

**Extrait 28 — `.github/workflows/ci.yml`, job `backend-tests`**

```yaml
on:
  push:
    branches: [maintenance, main]
  pull_request:
  workflow_dispatch:

jobs:
  backend-tests:
    name: Backend · tests (pytest)
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend
    env:
      MONGO_ENABLED: "false"
      JWT_SECRET_KEY: ci-test-secret
      ENVIRONMENT: test
    steps:
      - uses: actions/checkout@v4
      - name: Setup Python 3.12
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
          cache-dependency-path: backend/requirements.txt
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run tests
        run: pytest -q
```

Le second job, `frontend-build`, installe Node 22, exécute `npm ci` (installation reproductible depuis `package-lock.json`) puis `next build`, ce qui détecte les erreurs TypeScript et les imports cassés.

Pourquoi ce choix : les deux jobs tournent en parallèle et durent moins de deux minutes grâce au cache des dépendances. Les tests n'ont besoin d'aucun service externe (SQLite, Mongo désactivé, clé JWT de test), donc le pipeline ne dépend d'aucun secret. Le déclenchement manuel (`workflow_dispatch`) permet de relancer une exécution sans commit. Le pipeline ne couvre pas la qualité du code (lint) ni les tests du pipeline ETL ; les deux sont des ajouts simples, notés en perspective.

### Ce qui manque pour un déploiement continu

Le pipeline s'arrête au feu vert. Il n'y a ni construction d'image publiée, ni déploiement sur un serveur : l'application a toujours été exécutée sur les machines de l'équipe. Pour compléter la chaîne, il faudrait un job qui construit et pousse les images sur GitHub Container Registry, puis un déclenchement manuel qui exécute `docker compose pull && docker compose up -d` sur un serveur via SSH. Le choix de ne pas le faire tenait au coût d'un serveur et au temps disponible entre les deux dernières soutenances ; c'est la limite la plus nette de ce projet sur la compétence C11.

## 3. Supervision

### Métriques exposées par l'API

**Extrait 29 — `backend/app/main.py`, middleware de métriques**

```python
@fastapi_app.middleware("http")
async def prometheus_metrics_middleware(request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    # Route déjà résolue : on prend son gabarit (faible cardinalité), sinon "unmatched".
    route = request.scope.get("route")
    handler = getattr(route, "path", "unmatched") if route is not None else "unmatched"
    status_group = f"{response.status_code // 100}xx"
    HTTP_REQUESTS.labels(request.method, handler, status_group).inc()
    HTTP_LATENCY.labels(request.method, handler).observe(time.perf_counter() - start)
    return response


@fastapi_app.get("/metrics", include_in_schema=False)
def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
```

Pourquoi ce choix : les étiquettes utilisent le gabarit de route (`/api/me/{item_id}`) et non l'URL réelle, et la classe de statut (`2xx`, `5xx`) et non le code exact. Sans cela, chaque identifiant d'utilisateur créerait une série temporelle distincte et Prometheus saturerait en mémoire. C'est la règle de base de la cardinalité en supervision. Le compteur et l'histogramme suffisent à calculer le débit, le taux d'erreur et les percentiles de latence.

### Tableau de bord Grafana

*Figure 40 — Tableau de bord Grafana `healthai` (capture `dossier/figures/captures/fig40_grafana_dashboard.png`).*

Le tableau de bord est provisionné automatiquement (`monitoring/grafana/provisioning/`) au démarrage de la pile de supervision, avec six panneaux : requêtes par seconde, latence p95, erreurs 5xx par seconde, requêtes par endpoint, requêtes par statut, latence p50/p95/p99. Prometheus interroge `/metrics` toutes les quinze secondes.

*Figure 41 — Journal des appels IA, `GET /api/ai/ai-calls/history` : un appel Ollama en statut `fallback`, modèle indisponible (capture Playwright, `dossier/figures/captures/fig41_journal_appels_ia.png`).*

La supervision applicative est complétée par le journal des appels IA en MongoDB : pour chaque appel, le fournisseur, le modèle, la durée en millisecondes et le statut (`success`, `fallback`, `error`, `unavailable`). C'est ce journal qui permet de répondre à « combien d'analyses de repas échouent, et pourquoi ».

## 4. Maintenance

### Maintenance corrective réalisée : le panneau 5xx

Le 2 juillet 2026, en préparant la démonstration, le panneau « Erreurs 5xx / s » du tableau de bord affichait « No data » au lieu de zéro. Le symptôme était trompeur : un exploitant ne peut pas distinguer « aucune erreur » de « la métrique ne remonte pas ».

La cause était dans la requête PromQL. `sum(rate(http_requests_total{status="5xx"}[5m]))` ne renvoie rien tant qu'aucune requête n'a jamais produit de 5xx, parce que la série n'existe pas encore. Le correctif (commit `f6a29aa`) ajoute `or vector(0)` pour renvoyer explicitement zéro, et fixe `noValue: "0"` sur le panneau. La vérification a consisté à recharger le tableau de bord sur une pile fraîche, puis à provoquer une erreur 5xx et à observer le passage à une valeur non nulle.

```diff
- "expr": "sum(rate(http_requests_total{status=\"5xx\"}[5m]))"
+ "expr": "sum(rate(http_requests_total{status=\"5xx\"}[5m])) or vector(0)"
```

Ce cas illustre la démarche attendue : reproduire, isoler la cause, corriger au bon niveau (la requête, pas le middleware), vérifier, et laisser une trace dans l'historique.

### Maintenance issue de la veille et du jeu d'essai

Les correctifs suivants découlent de la relecture du code pour ce dossier et de la veille décrite en section XI. Ils sont réalisés sur une branche `cda/security-hardening` du dépôt de référence, un commit par point, chacun accompagné d'un test.

| Origine | Constat | Correctif | Test |
|---|---|---|---|
| Veille OWASP (stockage des mots de passe) | 210 000 itérations PBKDF2 | 600 000 itérations pour les nouveaux condensés ; les anciens restent vérifiables grâce au format auto-descriptif | `test_password_hash_uses_600k_iterations` |
| Veille OWASP (JWT) | JWT implémenté avec `hmac` | Passage à PyJWT, vérification de `exp` et du type de jeton | `test_auth_security.py` (repris de la branche de juin) |
| Veille ANSSI (configuration) | Clé de signature par défaut acceptée | Échec au démarrage si `JWT_SECRET_KEY` vaut la valeur par défaut avec `ENVIRONMENT=production` | `test_settings_reject_default_secret_in_production` |
| Relecture | `/metrics` accessible publiquement sur le port 8000 | Restriction au réseau Docker (Prometheus seul) | vérification manuelle |
| Jeu d'essai, écart 1 | Aliment à score faible recommandé pour combler la liste | Seuil de pertinence à 65 et message « catalogue insuffisant » | `test_nutrition_rejects_low_score_candidates` |
| Jeu d'essai, écart 2 | Durées des exercices et de la séance incohérentes | Calcul de la durée unitaire après sélection, durée de séance = somme | `test_session_duration_matches_exercises` |

Ces correctifs sont de la maintenance évolutive au sens du référentiel : ils ne changent pas les fonctionnalités, ils relèvent le niveau de sécurité et de fiabilité à partir d'informations recueillies par la veille. L'état d'avancement de cette branche sera à jour au moment de la soutenance.
