# XIII. Annexes (≤ 40 pages)

| Annexe | Contenu | Source | Pages estimées |
|---|---|---|---|
| A | Scripts de base de données : `schema_v1_2026-04-25.sql` (intégral), `migration_v2_2026-06.sql` (intégral), tableau de cohérence ORM ↔ base | `backend/db/`, `dossier/annexes/annexe_A_base_de_donnees.md` | 10 |
| B | Orchestration et intégration continue : `docker-compose.yml`, `docker-compose.monitoring.yml`, `.github/workflows/ci.yml`, `backend/Dockerfile`, `frontend/Dockerfile` | dépôt | 4 |
| C | Documentation d'exploitation : `docs/MAINTENANCE.md`, `Makefile`, `scripts/backup.sh`, `scripts/restore.sh` | dépôt | 4 |
| D | Supervision : `monitoring/prometheus/prometheus.yml`, export du tableau de bord Grafana (`healthai.json`, extraits), captures | dépôt, banque de captures | 3 |
| E | Captures d'écran complémentaires des trois espaces (deux par espace) | banque de captures, Playwright | 4 |
| F | Référentiel de données : sources Kaggle (noms, URL, licences), extraits de cinq lignes de chaque fichier source, les quinze règles de qualité seedées | sujet TPRE501, `data/`, `etl_common.py` | 4 |
| G | Contrat d'API : liste des endpoints par tag extraite d'`/api/openapi.json` | dépôt | 3 |
| H | Jeu d'essai : `jeu_essai_recommandations.py` et `sortie.json` (intégraux) | `dossier/jeu_essai/` | 3 |
| I | Audits de dépendances du 2 septembre 2026 : sorties de `pip-audit` et `npm audit` | `dossier/veille/` | 2 |
| J | Grilles d'évaluation des trois MSPR (Bloc 1, Bloc 2, Blocs 3/4) | fournies par l'EPSI | 3 |
| K | Glossaire : ETL, staging, upsert, JWT, PBKDF2, Argon2id, persistance polyglotte, RBAC, RGPD art. 9, RGAA, RGESN, LLM, IMC | rédigé | 1 |

Total estimé : 41 pages — l'annexe A sera réduite (script v1 en corps 8) ou les captures de l'annexe E limitées pour tenir sous 40.
