# XI. Veille sur les vulnérabilités de sécurité

## 1. Organisation de la veille

La veille a été structurée en trois axes lors de la troisième MSPR, et c'est ce découpage que je conserve : technologique (les briques du projet), réglementaire (données de santé, accessibilité) et sécurité (vulnérabilités et bonnes pratiques). Chaque axe a ses sources, sa fréquence et, surtout, une trace de ce qu'il a changé dans le projet. Une veille qui ne produit aucune décision n'est qu'une lecture.

| Axe | Sources | Fréquence | Support |
|---|---|---|---|
| Sécurité | CERT-FR (alertes et avis de l'ANSSI), base CVE / NVD, GitHub Advisory Database, alertes Dependabot sur le dépôt, OWASP (Top 10, Cheat Sheet Series), notes de version de FastAPI, Next.js, SQLAlchemy et PyMongo | hebdomadaire, plus à chaque montée de version | flux RSS, notifications GitHub |
| Technologique | Blogs et dépôts de FastAPI, Next.js, Ollama ; documentation Gemini ; publications sur les modèles de vision et les LLM locaux | hebdomadaire | lecteur RSS, listes de diffusion |
| Réglementaire | CNIL (données de santé, guides RGPD), France Compétences, référentiels RGAA et RGESN, actualité de l'AI Act | mensuelle | site de la CNIL, DINUM |

Deux outils automatisent l'axe sécurité sur le projet : `pip-audit` pour les dépendances Python et `npm audit` pour le frontend. Ils sont exécutés avant chaque livraison, et leurs sorties sont conservées.

## 2. État des dépendances au 2 septembre 2026

Les deux audits ont été exécutés sur la branche de référence pour ce dossier. Ce sont les résultats réels, pas un exemple.

**`pip-audit -r backend/requirements.txt`** : une vulnérabilité, sur `pytest` 8.4.2 (PYSEC-2026-1845, corrigée en 9.0.3). Elle ne concerne que l'outil de test, jamais l'image de production ; elle sera corrigée en relevant la borne de `requirements.txt`.

**`npm audit`** sur `frontend/package-lock.json` : quatre vulnérabilités de sévérité haute, toutes avec un correctif disponible.

| Paquet | Plage vulnérable | Nature | Impact pour HealthAI | Décision |
|---|---|---|---|---|
| `next` | 9.3.4 → 16.3.0 (avis GHSA-267c-6grr-h53f, GHSA-m99w-x7hq-7vfj, GHSA-955p-x3mx-jcvp et autres) | Contournement de middleware, déni de service via Server Actions, divulgation d'endpoints de fonctions serveur, confusion de cache | Le projet n'utilise ni middleware Next.js ni Server Actions : le contrôle d'accès est dans l'API. Le risque résiduel porte sur le déni de service et le cache | Corrigé le 2026-09-04 (branche `fix/npm-audit`) : `next` 15.5 → 16.3.4 par `npm install next@latest`, `next build` et les 54 tests backend passent, `npm audit` à 0 vulnérabilité (`dossier/veille/npm-audit_2026-09-04.txt`) |
| `postcss` | ≤ 8.5.22 | XSS via `</style>` non échappé dans la sortie, lecture de fichiers via `sourceMappingURL` | PostCSS ne traite que les feuilles de style du projet au moment du build, jamais de contenu utilisateur | Corrigé le 2026-09-04 par `npm audit fix` (branche `fix/npm-audit`) |
| `sharp` | < 0.35.0 | Vulnérabilités héritées de libvips (CVE-2026-33327, -33328, -35590, -35591) | `sharp` est utilisé par l'optimisation d'images de Next.js ; les photos de progression et de repas sont servies par l'API, pas par Next.js | Corrigé le 2026-09-04 par `npm audit fix` ; rendu des GIF vérifié par le build et le parcours M1 |
| `nanoid` | ≤ 3.3.17 | Dépendance transitive | Aucun usage direct | Corrigé le 2026-09-04 par la montée des autres paquets |

La montée de version de Next.js est le point à traiter avec le plus de soin : elle peut modifier le comportement de l'App Router. Elle sera faite sur une branche dédiée, validée par la CI (build + tests) puis par les parcours manuels M1 à M3 de la section IX.

## 3. Décisions issues de la veille pendant le projet

Le tableau ci-dessous relie chaque information de veille à ce qu'elle a changé dans le code. Les décisions de juin sont celles présentées à la troisième soutenance ; celles de septembre sont celles de la branche `cda/security-hardening` décrite en section X.

| Date | Source | Information | Décision | Trace |
|---|---|---|---|---|
| avril 2026 | OWASP Cheat Sheet « Session Management », documentation MDN sur les cookies | Un jeton en `localStorage` est lisible par tout script injecté ; un cookie `HttpOnly` + `SameSite` ne l'est pas | Jeton d'accès court en mémoire, jeton de rafraîchissement en cookie `HttpOnly`, `SameSite=Strict` | `modules/auth.py`, `frontend/src/lib/api.ts` |
| avril 2026 | OWASP « Authentication Cheat Sheet » | Limiter les tentatives de connexion et de réinitialisation | `slowapi` : 10/min sur la connexion, 5/min sur la réinitialisation | `core/rate_limit.py`, `modules/auth.py` |
| juin 2026 | CNIL, fiches sur les données de santé ; RGPD art. 9 | Les recommandations calculées sur des profils de santé doivent limiter les transferts hors de l'infrastructure | LLM local (Ollama) pour tout traitement de profil ; fournisseur cloud réservé aux photos de repas, désactivé sans clé | `services/ai_enhanced.py`, `config.py` |
| juin 2026 | Notes de version PyMongo, retours d'expérience sur les délais de sélection de serveur | Le délai par défaut de 30 s fige l'application quand la base est absente | `serverSelectionTimeoutMS` à 800 ms, cache d'échec de 20 s | `db/mongo.py` |
| juin 2026 | OWASP « JWT Cheat Sheet », CERT-FR | Ne pas implémenter soi-même la vérification de jetons ; vérifier l'expiration et le type | PyJWT, contrôle des secrets faibles au démarrage (branche d'intégration, non fusionnée dans la version de référence) | `mspr-healthai`, commit du 25 juin 2026 |
| juillet 2026 | Documentation Prometheus, article « cardinality is key » | Une étiquette à forte cardinalité fait exploser la mémoire du serveur de métriques | Étiquettes limitées au gabarit de route et à la classe de statut | `main.py`, middleware de métriques |
| juillet 2026 | CIS Docker Benchmark, guide ANSSI sur la conteneurisation | Ne pas exécuter les processus en root ; lier les ports d'administration à l'hôte local | Utilisateur `app` dans le Dockerfile ; MariaDB, MongoDB, Prometheus et Grafana sur `127.0.0.1` | `Dockerfile`, `docker-compose*.yml` |
| septembre 2026 | OWASP « Password Storage Cheat Sheet » (édition 2024) | 600 000 itérations pour PBKDF2-HMAC-SHA256, ou Argon2id | Itérations portées à 600 000 sur la branche `cda/security-hardening` | section X |
| septembre 2026 | ANSSI, « Recommandations pour la sécurisation des sites web » | Aucune valeur par défaut pour les secrets ; refuser de démarrer en production avec une configuration faible | Échec au démarrage si `JWT_SECRET_KEY` vaut la valeur par défaut avec `ENVIRONMENT=production` | section X |
| septembre 2026 | `pip-audit`, `npm audit` | Voir tableau ci-dessus | Montée de version de `next`, `postcss`, `sharp`, `pytest` ; audit npm à zéro le 2026-09-04 | section X, `dossier/veille/` |

## 4. Veille réglementaire et éthique

Trois sujets ont été suivis sans donner lieu à du code, mais en orientant des choix :

- **Données de santé et RGPD.** L'application traite des catégories particulières de données (article 9). Le projet s'appuie sur une base de licéité de consentement explicite lors de l'inscription, la minimisation du profil, et le droit d'accès par l'export. Un déploiement réel exigerait une analyse d'impact (AIPD) et, pour l'hébergement, la certification HDS ; ce sont les deux premières actions à mener avant toute mise en service.
- **AI Act.** Un outil de recommandations de bien-être sans finalité médicale relève d'un risque limité, avec une obligation de transparence : l'utilisateur doit savoir qu'il interagit avec un système automatisé. Les messages `source` (« local_rules », « ollama-llama3.2 », « gemini-2.5-flash ») renvoyés par l'API et affichés dans l'interface répondent à cette obligation.
- **Accessibilité (RGAA) et éco-conception (RGESN).** Le RGAA niveau AA était un critère du cahier des charges de la première MSPR ; les points appliqués sont listés en section VIII. Le RGESN a guidé le choix d'un modèle local léger et la pagination systématique.

## 5. Vulnérabilités anticipées

La veille sert aussi à nommer ce qui n'a pas encore été traité. Trois points sont identifiés et non corrigés :

1. **Téléversement d'images.** L'analyse de repas accepte tout fichier de moins de 10 Mo. Le type MIME n'est pas vérifié par le contenu (nombres magiques), seulement par l'en-tête. Un fichier non image est rejeté par le modèle, pas par l'API. Correction envisagée : validation par `python-magic` et redimensionnement avant envoi.
2. **Injection de consigne dans le LLM.** Le profil déclaratif de l'utilisateur (allergies, préférences en texte libre) est injecté dans le prompt d'Ollama. Un utilisateur pourrait y écrire une consigne. L'impact est limité à sa propre recommandation, mais le contenu généré devrait être filtré avant affichage.
3. **Absence de HTTPS local.** Le cookie de rafraîchissement n'est marqué `secure` qu'en production. Un déploiement doit impérativement passer derrière un reverse proxy TLS (Caddy ou Traefik), ce qui fait partie du plan de déploiement continu évoqué en section X.
