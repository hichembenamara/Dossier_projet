# VII. Spécifications techniques

## 1. Choix techniques et alternatives étudiées

*Figure 25 — Tableau comparatif des choix techniques (tableau Word).*

| Brique | Retenu | Alternatives étudiées | Critères décisifs |
|---|---|---|---|
| Langage serveur | Python 3.12 | TypeScript (NestJS, essayé en avril) | Un seul langage pour l'ETL, l'API et les appels aux modèles d'IA ; compétences de l'équipe |
| Framework API | FastAPI | Django REST Framework, Flask | Documentation OpenAPI générée depuis Pydantic ; injection de dépendances adaptée au contrôle d'accès ; asynchrone natif pour les appels IA longs |
| ORM et migrations | SQLAlchemy 2.0 | Prisma (avec NestJS), requêtes SQL brutes | Style `select()` typé, mixins, génération du schéma ; compatibilité MariaDB sans retouche |
| Base relationnelle | MariaDB 10.11 | PostgreSQL, MySQL | Imposée par le socle de la première MSPR ; compatible avec les outils déjà utilisés en formation |
| Base documentaire | MongoDB 7 avec PyMongo | Motor (asynchrone), stockage JSON en colonne MariaDB | Sujet exigeant une base NoSQL distincte ; PyMongo suffit pour des écritures courtes et non bloquantes |
| Frontend | Next.js 15, React 19, TypeScript | Vite + React, Angular | Routage par dossier qui reflète les trois rôles, TypeScript de bout en bout, écosystème de composants |
| État serveur | TanStack Query 5 | Redux, SWR | Cache et invalidation sans code de plomberie ; pagination et rejeu des requêtes |
| Formulaires | react-hook-form + zod | Formik | Validation typée partagée avec les types du domaine |
| Graphiques | Recharts | Chart.js, D3 | Composants React déclaratifs, suffisants pour des courbes et histogrammes |
| Vision par ordinateur | Gemini 2.5 Flash (cloud) | Hugging Face (`nateraw/food`, BLIP), DeepSeek | Multimodal avec réponse JSON exploitable ; les modèles Hugging Face ont été testés puis conservés en repli historique |
| LLM texte | Ollama, modèle `llama3.2:1b` (local) | API cloud | Les profils de santé ne quittent pas la machine ; modèle léger exécutable sur un portable |
| Détection de posture | MediaPipe Tasks Vision (navigateur) | OpenPose côté serveur | Aucune vidéo envoyée au serveur ; latence nulle |
| Conteneurs | Docker Compose | Kubernetes, installation manuelle | Cinq services orchestrés d'une commande ; profils pour l'ETL et la supervision |
| Intégration continue | GitHub Actions | GitLab CI, Jenkins | Dépôt déjà sur GitHub ; exécution gratuite |
| Supervision | Prometheus + Grafana | Datadog, logs seuls | Standard ouvert, métriques exposées par l'API sans agent |

### Le choix FastAPI en détail

La section II raconte la tentative NestJS et son abandon. Sur le plan technique, trois arguments ont pesé.

Le premier est la documentation. Le sujet exigeait une API « documentée via OpenAPI ». Avec FastAPI, chaque schéma Pydantic déclaré en `response_model` apparaît dans `/api/docs` sans autre effort ; les 29 tests de contrat de `test_api_contracts.py` vérifient que ces schémas restent stables.

Le deuxième est l'injection de dépendances. Le contrôle d'accès s'écrit comme un paramètre de route : `Depends(current_user)` pour exiger une session, `Depends(require_roles("ADMIN"))` pour exiger un rôle. Cette composition rend les règles de sécurité lisibles à l'endroit où elles s'appliquent.

Le troisième est la reconnexion à la base. Après un redémarrage du conteneur MariaDB, les connexions du pool sont mortes. L'option `pool_pre_ping=True` de SQLAlchemy teste la connexion avant chaque utilisation et la recrée si nécessaire, ce qui évite les erreurs « MySQL server has gone away » observées pendant les démonstrations.

**Extrait 5 — `backend/app/db/session.py`, création du moteur**

```python
def get_engine() -> Engine:
    global engine
    if engine is None:
        engine = create_engine(
            get_settings().sqlalchemy_database_url,
            pool_pre_ping=True,
            future=True,
        )
    return engine


def get_db() -> Generator[Session, None, None]:
    with get_session_factory()() as db:
        yield db
```

Pourquoi ce choix : le moteur est créé une seule fois, à la première demande, ce qui permet aux tests de remplacer l'URL par une base SQLite en mémoire avant toute connexion. `get_db` est la dépendance injectée dans chaque route ; la session est fermée automatiquement à la fin de la requête, même en cas d'exception.

## 2. Environnements

*Figure 26 — Tableau des environnements (tableau Word).*

| | Développement | Intégration continue | Démonstration |
|---|---|---|---|
| Base relationnelle | MariaDB 10.11 (conteneur `db`) | SQLite en mémoire (`sqlite+pysqlite:///:memory:`) | MariaDB 10.11 |
| Base documentaire | MongoDB 7 (conteneur `mongo`) | désactivée (`MONGO_ENABLED=false`) | MongoDB 7 |
| Fournisseurs d'IA | Ollama local, Gemini si clé | aucun (mocks) | Ollama local, Gemini si clé |
| Supervision | optionnelle (`make monitoring-up`) | — | Prometheus + Grafana |
| Commandes | `make up`, `make etl`, `pytest -q` | `pytest -q` puis `npm ci && npm run build` | `make up`, `make monitoring-up`, `make backup` |
| Comptes | `user`, `admin`, `superadmin` créés au démarrage hors production | fixtures | comptes de démonstration |

La configuration est lue par `pydantic-settings` depuis les variables d'environnement, avec `.env.example` comme modèle. Aucun secret n'est versionné ; le fichier `.env` est ignoré par Git.

### Conteneurisation

**Extrait 6 — `backend/Dockerfile`**

```dockerfile
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 1000 --shell /bin/bash app

COPY --chown=app:app requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

COPY --chown=app:app app ./app

USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8000/health || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Pourquoi ce choix : l'image part de `python:3.12-slim` pour limiter la surface d'attaque et la taille ; le processus tourne sous un utilisateur non privilégié (`app`), comme le recommandent le CIS Docker Benchmark et l'ANSSI ; les dépendances sont copiées avant le code pour profiter du cache de construction ; le `HEALTHCHECK` interroge `/health`, ce qui permet à Docker Compose d'attendre que l'API soit prête avant de démarrer le frontend (`depends_on` avec `condition: service_healthy`).

## 3. Spécifications de sécurité

La sécurité est structurée selon l'OWASP Top 10 (édition 2021), grille connue des jurys et des recruteurs. Le tableau indique, pour chaque risque pertinent, la mesure présente dans le dépôt de référence et l'endroit où la lire.

| Risque OWASP | Mesure dans HealthAI Coaching | Où |
|---|---|---|
| A01 Broken Access Control | Trois rôles vérifiés à chaque requête ; filtrage des ressources par propriétaire (`owner_field`) ; garde de rôle côté client en complément | `core/security.py` (`require_roles`), `modules/resources.py` (`_base_query`), `frontend/src/components/role-guard.tsx` |
| A02 Cryptographic Failures | Mots de passe hachés en PBKDF2-HMAC-SHA256 avec sel aléatoire de 16 octets et 210 000 itérations ; comparaison en temps constant (`hmac.compare_digest`) ; jetons signés HMAC-SHA256 | `core/security.py` |
| A03 Injection | Requêtes paramétrées par SQLAlchemy ; entrées validées par Pydantic ; liste blanche des colonnes de tri et de recherche dans le CRUD générique | `schemas/`, `modules/resources.py` |
| A04 Insecure Design | Base documentaire et fournisseurs d'IA déclarés non critiques : dégradation gracieuse plutôt que panne | `db/mongo.py`, `services/document_store.py`, `modules/ai_features.py` |
| A05 Security Misconfiguration | Liste blanche CORS ; secrets en variables d'environnement ; ports des bases et de la supervision liés à `127.0.0.1` ; conteneur non root | `main.py`, `config.py`, `docker-compose*.yml`, `Dockerfile` |
| A07 Identification and Authentication Failures | Jeton d'accès court (30 min) en mémoire ; jeton de rafraîchissement en cookie `HttpOnly` + `SameSite=Strict` ; limitation à 10 connexions par minute et 5 demandes de réinitialisation par minute ; comptes désactivables (`statut`) | `modules/auth.py`, `core/rate_limit.py` |
| A08 Software and Data Integrity Failures | Dépendances épinglées par plage de versions ; images de base à version fixe ; `npm ci` en CI | `requirements.txt`, `package-lock.json`, `Dockerfile`, `ci.yml` |
| A09 Security Logging and Monitoring Failures | Identifiant de requête propagé (`x-request-id`) ; journal de chaque appel IA dans `ai_provider_calls` ; métriques Prometheus par route et par classe de statut | `core/middleware.py`, `services/document_store.py`, `main.py` |
| A10 Server-Side Request Forgery | Les seules URL sortantes sont celles des fournisseurs d'IA, lues dans la configuration, jamais dans les requêtes | `config.py`, `services/ai_enhanced.py` |

Les risques A06 (composants vulnérables) sont traités en section XI par la veille et les audits de dépendances.

### Points assumés et traités en maintenance

Le dépôt de référence présente trois écarts par rapport aux recommandations actuelles, que la relecture du code a fait ressortir et que je préfère annoncer ici plutôt que laisser le jury les découvrir.

Le premier concerne les bibliothèques cryptographiques. Le JWT et le PBKDF2 sont implémentés avec la bibliothèque standard (`hmac`, `hashlib`, `secrets`) plutôt qu'avec PyJWT ou passlib. L'argument initial se défend : aucune dépendance supplémentaire, mécanique comprise ligne par ligne, format de condensé auto-descriptif (`pbkdf2_sha256$itérations$sel$hash`) qui permet de migrer le nombre d'itérations sans invalider les comptes. La limite est tout aussi claire : pas de rotation de clé, pas de vérification des revendications standard (`iss`, `aud`), et une implémentation maison n'est pas relue par la communauté. J'avais d'ailleurs basculé sur PyJWT dans la branche d'intégration de juin.

Le deuxième concerne le nombre d'itérations. La fiche OWASP de stockage des mots de passe recommande 600 000 itérations pour PBKDF2-HMAC-SHA256 ; 210 000 correspondait à la valeur par défaut de Django en 2021.

Le troisième concerne la clé de signature : `jwt_secret_key` a une valeur par défaut (`change-me-in-production`) et rien n'empêche de démarrer en production avec. Là encore, le contrôle au démarrage existait dans la branche de juin.

Ces trois points font l'objet de correctifs décrits en section X (maintenance corrective) et rattachés à la veille de la section XI : passage à PyJWT, itérations portées à 600 000 ou remplacement par Argon2id, échec au démarrage si la clé par défaut est détectée avec `ENVIRONMENT=production`, et restriction de `/metrics` au réseau Docker.

### Conformité aux données de santé

Au-delà de l'OWASP, trois mesures découlent directement du caractère sensible des données :

- **Minimisation** : le profil déclaratif (allergies, contraintes, équipements) n'est demandé que parce que le moteur de recommandations l'utilise ; aucune donnée d'identité au-delà du nom et de l'email.
- **Cloisonnement** : un administrateur n'accède qu'aux utilisateurs de son organisation ; un utilisateur n'accède qu'à ses propres mesures, ce que garantit le filtre `owner_field` du CRUD générique et non l'interface.
- **Souveraineté des traitements IA** : les recommandations textuelles sont produites par un modèle local ; seule l'analyse de photo de repas, qui ne contient pas de données de santé, transite par un fournisseur cloud, et uniquement si l'exploitant fournit une clé.
