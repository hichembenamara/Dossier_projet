# V. Gestion de projet

## 1. Méthode

Le projet n'a pas suivi Scrum au sens strict : pas de sprints à durée fixe, pas de vélocité mesurée. Il a suivi une méthode itérative dictée par le calendrier des trois MSPR, avec trois lots de livraison, chacun découpé en périmètres attribués à un membre de l'équipe, des points d'avancement réguliers, et une relecture croisée avant fusion. Je préfère le décrire tel qu'il a été vécu ; le jury CDA évalue la capacité à contribuer à un projet, pas la récitation d'un vocabulaire.

### Les trois lots

| Lot | Période | Objectif | Contenu livré |
|---|---|---|---|
| L1 — Socle données | déc. 2025 → 30 avr. 2026 | Base relationnelle, pipeline ETL, API, interfaces par rôle | 19 tables, 5 scripts ETL, 15 règles de qualité, API FastAPI, 3 espaces Next.js |
| L2 — Intelligence artificielle | 1er → 29 juin 2026 | Recommandations, vision, coach posture, persistance NoSQL | Moteur de règles + Ollama, Gemini Vision, MediaPipe, 4 collections MongoDB, micro-service d'intégration |
| L3 — Production | 24 juin → 3 juil. 2026 | Intégration continue, supervision, sauvegarde, résilience | GitHub Actions, Prometheus/Grafana, backup/restore, mode dégradé, 39 tests automatisés |

À l'intérieur du lot 1, le backend a lui-même été construit en cinq lots fonctionnels visibles dans l'historique Git d'avril : socle et authentification, espace utilisateur, sport et nutrition, administration et ETL, super-administration et exports.

### Ce qui n'a pas été fait

Il n'y a pas eu de planning prévisionnel formalisé au démarrage de chaque lot, ni d'estimation par tâche. Les échéances étaient les dates de soutenance ; le contenu s'ajustait à ce qui était faisable avant. Cela a fonctionné pour trois livraisons validées, mais au prix de journées très denses en fin de lot (le 26 avril, le 25 juin) et d'au moins une fausse route coûteuse, la réécriture NestJS décrite en section II. Avec le recul, un jalonnement daté par périmètre, même sommaire, aurait fait apparaître plus tôt les points de tension : c'est ce que je mets en place pour la préparation de ce dossier, avec un plan en phases et une liste de reste à faire tenue à jour.

## 2. Planning réalisé et suivi

*Figure 5 — Chronogramme réalisé du projet, décembre 2025 → juillet 2026 (archify, `dossier/figures/archify/fig05_chronogramme_realise.png`).*

Repères principaux, tels que l'historique Git les date :

| Date | Événement |
|---|---|
| 17 déc. 2025 | Création du dépôt initial, socle DevOps (Docker Compose, lint, guide d'installation) |
| 4-5 fév. 2026 | Diagrammes Merise, dictionnaire de données, premier backend FastAPI (SQLAlchemy 2.0, CRUD, audit, OpenAPI) |
| 23-24 fév. | Restructuration ETL + backend dans un dépôt commun |
| 1er avr. | Fusion du socle DevOps et du backend |
| 25-28 avr. | Sprint final du lot 1 : ETL, backend Nest abandonné puis FastAPI consolidé, Docker, seed, frontend |
| 30 avr. | Soutenance Bloc 1 — validée |
| 9-13 juin | Service de vision Gemini, intégration MariaDB |
| 23-25 juin | Intégration du micro-service IA, sécurité, CI, tests, rapport technique |
| 29 juin | Soutenance Bloc 2 — validée |
| 24 juin → 2 juil. | Branche `maintenance` : IA intégrée au backend, NoSQL, CI, backup, monitoring |
| 3 juil. | Soutenance Blocs 3/4 — validée |

*Figure 6 — Historique Git de la branche `maintenance` (`git log --oneline --graph`).*

Les quatorze commits de la branche de référence suivent la convention Conventional Commits (`feat(nosql):`, `fix(monitoring):`, `docs:`), ce qui permet de lire l'historique comme un journal : ajout des collections MongoDB, correctifs de parsing JSON du LLM, correctif du panneau Grafana, restauration de l'interface de recommandations d'origine.

### Suivi des tâches et communication

Le suivi s'est fait sur un tableau Trello par périmètre et sur un serveur Discord d'équipe, où se tenaient les points d'avancement et les échanges de relecture. Le tableau Trello n'a pas été conservé ; les échanges Discord existent mais ne sont pas reproduits ici. Ce dossier s'appuie donc sur ce qui est vérifiable : les dépôts, leurs commits, et les trois supports de soutenance.

### Dérives et décisions

Quatre décisions ont modifié la trajectoire prévue, toutes tracées :

1. **Abandon du backend NestJS** (27 avril) pour revenir à FastAPI — voir section II.
2. **Abandon de Hugging Face et DeepSeek** pour la vision (juin) : latence trop élevée et sorties non structurées ; Gemini 2.5 Flash retenu pour son mode JSON, Hugging Face conservé en repli historique dans `meal_analysis.py`.
3. **Pas de modèle entraîné** au lot 2 : arbitrage explicite entre un modèle « maison » aux métriques douteuses et un assemblage de modèles éprouvés derrière des règles explicables. Présenté comme écart assumé, validé par le jury.
4. **Divergence de juin** : le micro-service IA et le durcissement de sécurité que j'avais intégrés le 25 juin n'ont pas été repris dans la branche `maintenance`, qui a intégré l'IA directement dans le backend. La version de référence est celle de la troisième soutenance ; les apports non repris sont traités comme maintenance en sections X et XI.

## 3. Environnement humain

*Figure 7 — Organigramme de l'équipe et périmètres (archify, `dossier/figures/archify/fig07_organigramme_equipe.png`).*

| Membre | Périmètre principal | Sujets présentés à l'oral |
|---|---|---|
| Hicham Benamara | Modèle de données, base relationnelle, Docker et seed, intégration et sécurité, veille | SQL et ETL, NoSQL, RGPD, déploiement, sauvegardes, veille |
| Aedh Aljene | Pipeline ETL, interface de recommandations, cadrage | Cadrage, IA, moteur de recommandations, sécurité |
| Maxime Rousson | Frontend, services IA, CI, supervision, sauvegardes | Tableau de bord, architecture, tests, monitoring, méthode |

Les rôles n'étaient pas étanches : les commits montrent chacun intervenant sur le périmètre des autres (Aedh sur l'interface de recommandations, Maxime sur le backend en juillet, moi sur le pipeline ETL et l'intégration du service IA). Le formateur référent tenait le rôle du commanditaire ; les jurys, celui du public technique.

Rituels : points d'avancement sur Discord à chaque étape marquante, animés à tour de rôle ; relecture du code par un coéquipier avant fusion — une pull request avec correctifs de revue figure dans l'historique de juin ; comptes rendus par périmètre rédigés pour préparer chaque soutenance.

## 4. Environnement de travail

**Extrait 1 — `docker-compose.yml` (résumé des cinq services)**

```yaml
services:
  db:
    image: mariadb:10.11
    ports: ["127.0.0.1:3307:3306"]
    healthcheck:
      test: ["CMD", "mariadb-admin", "ping", "-h", "127.0.0.1", "-uroot", "-p${MYSQL_ROOT_PASSWORD:-root}"]
      interval: 10s
  mongo:
    image: mongo:7
    ports: ["127.0.0.1:27017:27017"]
    healthcheck:
      test: ["CMD", "mongosh", "--quiet", "--eval", "db.adminCommand('ping')"]
  backend:
    build: ./backend
    ports: ["${BACKEND_PORT:-8000}:8000"]
    volumes:
      - ./data:/app/data:ro
      - ./data/uploads:/app/data/uploads
    depends_on:
      db: { condition: service_healthy }
      mongo: { condition: service_healthy }
  frontend:
    build: ./frontend
    ports: ["${FRONTEND_PORT:-3000}:3000"]
    depends_on:
      backend: { condition: service_healthy }
  etl:
    build: ./healthai_etl
    profiles: ["etl"]
    depends_on:
      db: { condition: service_healthy }
```

Pourquoi ce choix : chaque membre travaille sur la même pile, quelle que soit sa machine (Windows, macOS et Linux ont tous été utilisés). Les `healthcheck` et les `depends_on` conditionnels règlent l'ordre de démarrage : le backend attend les deux bases, le frontend attend l'API, l'ETL attend la base relationnelle. Le profil `etl` évite de relancer l'import à chaque démarrage. Le répertoire `data/` est monté en lecture seule, sauf `uploads/` où l'API écrit les photos. Une fois démarré, le backend tolère l'arrêt de MongoDB (section VIII) ; la condition de santé au démarrage sert seulement à créer les index dès le premier appel.

**Extrait 2 — `.env.example` (variables principales)**

```ini
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=healthai
DB_PASSWORD=healthai
DB_NAME=healthai_coaching
MONGO_URL=mongodb://localhost:27017
MONGO_DB_NAME=healthai_nosql
MONGO_ENABLED=true
JWT_SECRET_KEY=change-me-local-dev
ENVIRONMENT=development
BACKEND_PORT=8000
FRONTEND_PORT=3000
NEXT_PUBLIC_API_URL=http://localhost:8000/api
AI_ENABLE_EXTERNAL_CALLS=false
MEAL_AI_FORCE_MOCK=false
MEAL_AI_TIMEOUT_SECONDS=30
MEAL_AI_MAX_IMAGE_BYTES=6000000
```

Pourquoi ce choix : la configuration est séparée du code (troisième facteur de la méthode « twelve-factor app ») ; le même code tourne en développement, en CI et en démonstration avec des valeurs différentes. Aucun secret n'est versionné, `.env` étant ignoré par Git ; les clés des fournisseurs d'IA (`GEMINI_API_KEY`, `OLLAMA_BASE_URL`) se déclarent selon `AI_SETUP.md`. `AI_ENABLE_EXTERNAL_CALLS=false` par défaut garantit qu'aucune donnée ne sort de la machine sans décision explicite de l'exploitant. La clé JWT d'exemple est volontairement reconnaissable comme factice ; c'est le contrôle au démarrage décrit en section X qui empêche de la garder en production.

*Figure 8 — Outils utilisés (tableau Word).*

| Catégorie | Outils |
|---|---|
| Conception | PlantUML (Merise), archify (diagrammes), draw.io |
| Bases de données | DBeaver, phpMyAdmin, MongoDB Compass, `mongosh` |
| Développement | VS Code, Python 3.12, Node 22, Git |
| Qualité et tests | pytest, ESLint, `pip-audit`, `npm audit` |
| Collaboration | GitHub, Discord, Trello |
| Exploitation | Docker Desktop, Grafana, Prometheus |

### Stratégie Git

*Figure 9 — Branches et flux de fusion (archify, `dossier/figures/archify/fig09_branches_git.png`).*

Branches de fonctionnalité (`feature/ai-recommendations-vision`) fusionnées dans `maintenance`, elle-même en avance sur `main`. Commits conventionnels. Avant la première soutenance, plusieurs dépôts ont coexisté au gré des essais (ETL seul, backend seul, version NestJS) ; c'est une source de confusion que je ne reproduirais pas : un dépôt, des branches.

## 5. Objectifs de qualité

Une définition de « terminé » implicite s'est imposée au lot 3, que je formalise ici : tests automatisés verts en CI, relecture par un coéquipier, documentation d'exploitation mise à jour, démonstration rejouée sur une pile fraîche. Les 39 tests, le `README`, `docs/MAINTENANCE.md` et la `CHECKLIST_SOUTENANCE.md` en sont les traces.

## 6. Matrice des risques

*Figure 10 — Matrice probabilité × impact (archify, `dossier/figures/archify/fig10_matrice_risques.png`).*

Chaque risque est associé à une contre-mesure réellement présente dans le code ou dans l'organisation ; ceux qui n'en ont pas sont marqués comme tels.

| # | Risque | Prob. | Impact | Contre-mesure | Où |
|---|---|---|---|---|---|
| R1 | Fournisseur d'IA cloud indisponible ou quota épuisé | Élevée | Moyen | Modèle local Ollama pour les recommandations ; 503 explicite pour la vision ; journal des appels | `ai_enhanced.py`, `ai_features.py` |
| R2 | Panne de la base documentaire | Moyenne | Faible | Mode dégradé : `get_mongo_db()` renvoie `None`, écritures ignorées, `/health` le signale | `mongo.py`, `document_store.py` |
| R3 | Fuite ou accès indu à des données de santé | Faible | Critique | Rôles, filtrage par propriétaire, hachage, cookie HttpOnly, cloisonnement par organisation | `security.py`, `resources.py`, `auth.py` |
| R4 | Perte de données | Faible | Critique | `backup.sh` / `restore.sh` testés ; **pas de planification ni de copie hors site** (limite) | `scripts/` |
| R5 | Sortie du LLM inexploitable (JSON invalide, hallucination) | Élevée | Moyen | Mode JSON d'Ollama, température basse, `_safe_json`, sélection restreinte au catalogue, repli déterministe | `ai_enhanced.py` |
| R6 | Données sources incohérentes | Élevée | Moyen | 15 règles de qualité, staging, décisions tracées, taux de qualité par exécution | `etl_common.py` |
| R7 | Dérive de calendrier en fin de lot | Élevée | Moyen | Découpage par périmètre, relecture croisée ; **pas de jalons intermédiaires** (limite) | organisation |
| R8 | Dépendances vulnérables | Moyenne | Moyen | `pip-audit`, `npm audit`, versions épinglées, audits du 2 septembre | section XI |
| R9 | Secret par défaut en production | Moyenne | Critique | Contrôle au démarrage (branche `cda/security-hardening`) | section X |
| R10 | Dépendance à une seule personne sur un périmètre | Moyenne | Moyen | Interventions croisées visibles dans les commits ; documentation d'exploitation | `docs/` |
