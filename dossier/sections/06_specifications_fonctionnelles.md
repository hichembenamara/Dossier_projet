# VI. Spécifications fonctionnelles

## 1. Contraintes et livrables

### Contraintes techniques

Le cahier des charges de la première MSPR demandait un socle « automatisé, sécurisé et reproductible », conçu pour accueillir plus tard des micro-services d'IA. Les MSPR suivantes ont ajouté l'obligation d'une API d'intelligence artificielle, d'un moteur de recommandation multi-critères et d'une persistance combinant une base relationnelle et une base NoSQL. Nous en avons tiré les contraintes suivantes, qui ont guidé toutes les décisions de conception :

- l'application doit démarrer entièrement avec Docker Compose, sans installation manuelle ;
- les données de santé restent sur l'infrastructure de l'équipe : les appels à un modèle distant sont optionnels et remplaçables par un modèle local (Ollama) ;
- chaque import de données doit être traçable ligne par ligne, du fichier brut jusqu'à la table métier ;
- l'API doit être documentée par OpenAPI et protégée par une authentification à trois rôles ;
- la panne d'un composant non critique (base documentaire, fournisseur d'IA) ne doit pas rendre l'application indisponible.

### Contraintes réglementaires

Les mesures biométriques, le sommeil, la tension artérielle ou les contraintes de santé déclarées à l'inscription sont des données de santé au sens de l'article 4 du RGPD, et relèvent des catégories particulières de l'article 9. Cela impose la minimisation (on ne collecte que ce qui sert aux recommandations), le hachage des mots de passe, le cloisonnement des accès par rôle et par organisation, et la possibilité pour l'utilisateur d'obtenir ses données (module `exports`). L'application ne pose aucun diagnostic médical ; les recommandations sont présentées comme des suggestions de bien-être.

Deux référentiels ont également été pris en compte, sans prétendre à une conformité complète : le RGAA pour l'accessibilité (libellés de formulaires, contrastes, navigation au clavier sur les écrans principaux) et le RGESN pour l'éco-conception (pagination des listes, modèle local léger `llama3.2:1b`, absence de rafraîchissement automatique des tableaux de bord).

### Livrables

| Livrable | Emplacement dans le dépôt |
|---|---|
| Code source de l'API, du frontend et de l'ETL | `backend/`, `frontend/`, `healthai_etl/` |
| Scripts de création et de migration de la base | `backend/db/schema_v1_2026-04-25.sql`, `backend/db/migration_v2_2026-06.sql` (annexe A) |
| Orchestration et supervision | `docker-compose.yml`, `docker-compose.monitoring.yml`, `monitoring/` |
| Documentation d'exploitation | `README.md`, `docs/MAINTENANCE.md`, `AI_SETUP.md`, `Makefile` |
| Pipeline d'intégration continue | `.github/workflows/ci.yml` |
| Scripts de sauvegarde et restauration | `scripts/backup.sh`, `scripts/restore.sh` |
| Tests automatisés | `backend/tests/`, `healthai_etl/tests/` |

## 2. Architecture logicielle

### Vue d'ensemble

*Figure 11 — Architecture d'exécution de HealthAI Coaching (archify, `dossier/figures/archify/fig11_architecture_execution.png`).*

L'application est composée de cinq conteneurs définis dans `docker-compose.yml` et de deux conteneurs de supervision définis à part :

| Conteneur | Rôle | Port exposé |
|---|---|---|
| `db` | MariaDB 10.11, source de vérité des données métier et du pilotage ETL | 3307 sur l'hôte (3306 interne) |
| `mongo` | MongoDB 7, sorties des services IA | 27017 |
| `backend` | API FastAPI, module IA inclus | 8000 |
| `frontend` | Next.js 16 | 3000 |
| `etl` | Pipeline Python, lancé à la demande (`--profile etl`) | — |
| `prometheus` | Collecte des métriques exposées par l'API | 9090 |
| `grafana` | Tableau de bord de supervision | 3001 |

Les ports des bases et de la supervision sont liés à `127.0.0.1` : ils ne sont accessibles que depuis la machine hôte, jamais depuis le réseau.

Le navigateur ne dialogue qu'avec le frontend et l'API. L'API est le point d'entrée unique vers les deux bases et vers les fournisseurs d'IA : Ollama en local (hors Compose, joint par `OLLAMA_BASE_URL`) et Gemini dans le cloud, activé seulement si une clé est fournie.

### Architecture en couches du backend

*Figure 12 — Découpage en couches du backend (archify, `dossier/figures/archify/fig12_couches_backend.png`, source `dossier/figures/sources/couches_backend.mmd`).*

Le backend suit une séparation en quatre couches, chacune dans un répertoire de `backend/app/` :

| Couche | Répertoire | Responsabilité | Exemples |
|---|---|---|---|
| Présentation | `modules/` | Routes HTTP, validation des entrées, codes de réponse | `auth.py`, `me.py`, `ai_features.py`, `admin.py`, `resources.py` |
| Contrats | `schemas/` | Modèles Pydantic d'entrée et de sortie, base de la documentation OpenAPI | `RecommendationRequest`, `MealAnalysisResponse` |
| Métier | `services/` | Règles de calcul, appels aux fournisseurs d'IA, écriture des documents | `recommendations.py`, `meal_analysis.py`, `ai_enhanced.py`, `document_store.py` |
| Accès aux données | `db/` | Modèles SQLAlchemy, sessions, client MongoDB | `models.py`, `session.py`, `mongo.py` |

Une couche transverse, `core/`, contient la configuration (`config.py`), la sécurité (`security.py`), la gestion des erreurs (`errors.py`), la pagination (`pagination.py`), la limitation de débit (`rate_limit.py`) et le middleware de journalisation (`middleware.py`).

Cette séparation a été choisie pour deux raisons vérifiables dans le code. D'abord la testabilité : les règles du moteur de recommandations se testent sans serveur HTTP (`tests/test_recommendation_rules.py`). Ensuite la remplaçabilité : le passage de Hugging Face à Gemini puis l'ajout d'Ollama se sont faits dans `services/`, sans toucher aux routes ni aux schémas.

### Persistance polyglotte

Les données structurées, relationnelles et durables (profils, mesures, séances, catalogue, traçabilité ETL) sont en MariaDB. Les documents produits par l'IA vont dans MongoDB, dans quatre collections gérées par `services/document_store.py` :

| Collection | Contenu | Écrite par |
|---|---|---|
| `food_analyses` | Résultat structuré d'une analyse de photo de repas | `POST /api/ai/analyse-repas` |
| `recommendations` | Recommandations générées, texte libre du LLM inclus | `POST /api/ai/recommandations` |
| `recommendation_feedback` | Retour de l'utilisateur sur une recommandation | `POST /api/ai/recommandations/feedback` |
| `ai_provider_calls` | Journal de chaque appel IA : fournisseur, modèle, durée, statut | toutes les routes IA |

Ces documents ont un schéma qui change à chaque évolution de prompt ou de fournisseur, et personne ne les interroge par jointure. Les mettre dans une table relationnelle aurait imposé des migrations à chaque changement de format. Le choix suit le principe de persistance polyglotte décrit par Martin Fowler : chaque type de donnée va dans le moteur qui lui convient.

Chaque collection reçoit un index composé `(utilisateur_id, created_at décroissant)`, créé à la première utilisation, parce que la seule lecture faite sur ces collections est « les derniers documents de cet utilisateur ».

*Figure 21 — Les quatre collections MongoDB et le mode dégradé (archify, `dossier/figures/archify/fig21_collections_mongo.png`).*

La base documentaire est déclarée non critique : si MongoDB est arrêté, `get_mongo_db()` renvoie `None`, les écritures sont ignorées avec un avertissement dans les journaux, et `GET /health` passe la clé `documentaire` à `unavailable`. L'API continue de répondre. Ce comportement a été démontré en direct lors de la troisième soutenance.

## 3. Charte graphique

*Figure 13 — Charte graphique : palette, typographies, composants de base (archify, `dossier/figures/archify/fig13_charte_graphique.png`).*

Le frontend utilise Tailwind CSS avec une palette définie dans `frontend/src/components/charts/palette.ts` pour les graphiques et dans la configuration Tailwind pour l'interface. Les composants de base sont regroupés dans `frontend/src/components/ui/` : `button`, `badge`, `cards`, `data-table`, `pagination`, `modal`, `tabs`, `forms`, `states` (chargement, vide, erreur). Les trois espaces partagent la même coque applicative (`app-shell.tsx`) avec une barre latérale dont le contenu dépend du rôle.

## 4. Maquettage

Les maquettes présentées ici ont été réalisées après le développement, à partir des écrans livrés. Le projet a démarré directement à partir du cahier des charges et des jeux de données, sans phase de maquettage formelle ; c'est une des choses que je ferais autrement, comme indiqué en section V.

*Figure 14 — Zoning du tableau de bord utilisateur (archify, `dossier/figures/archify/fig14_zoning_dashboard.png`).*
*Figure 15 — Wireframe du tableau de bord utilisateur (archify, `dossier/figures/archify/fig15_wireframe_dashboard.png`).*
*Figure 16 — Maquette haute fidélité du tableau de bord utilisateur (capture `dossier/figures/captures/fig16_maquette_dashboard.png`).*

Le tableau de bord utilisateur (`/me/dashboard`) est l'écran de référence : une rangée d'indicateurs (poids, IMC, sommeil, séances, plats, calories du journal), deux graphiques d'évolution (poids/IMC et sommeil), l'objectif actif, la dernière photo de progression, puis les dernières séances et les derniers repas.

*Figure 14b — Zoning de l'écran des exécutions ETL, `/admin/etl/executions` (archify, `dossier/figures/archify/fig14b_zoning_etl_executions.png`).*
*Figure 15b — Wireframe de l'écran des exécutions ETL (archify, `dossier/figures/archify/fig15b_wireframe_etl_executions.png`).*

L'écran des exécutions ETL est le second écran maquetté, côté administrateur : une barre de filtre sur le statut, un tableau paginé (identifiant, statut, démarrage, lignes valides et invalides, taux de qualité, message) alimenté par `GET /api/executions-etl`, et un clic sur une ligne qui ouvre le détail de l'exécution puis les contrôles qualité du lot. La page réutilise les composants `Page` et `CrudList` communs aux listes d'administration.

*Figure 14c — Zoning de l'écran des recommandations, `/me/recommandations` (archify, `dossier/figures/archify/fig14c_zoning_recommandations.png`).*
*Figure 15c — Wireframe de l'écran des recommandations (archify, `dossier/figures/archify/fig15c_wireframe_recommandations.png`).*

L'écran des recommandations est le troisième : deux cartes de choix (repas et recettes, séance de sport) précèdent un formulaire pré-rempli depuis `GET /api/me/profile`, puis une zone de résultats à droite (scores repas ou sport et sécurité, source de la réponse, contexte pris en compte, cartes explicables). La génération passe par `POST /api/ai/recommandations` ; sans clé IA configurée, la carte Source indique « Fallback local » et seules les règles métier répondent.

*Figure 17 — Diagramme de navigation des trois espaces (archify, `dossier/figures/archify/fig17_navigation_ecrans.png`).*

Les 34 routes du frontend se répartissent ainsi :

| Espace | Routes |
|---|---|
| Public | `/`, `/login`, `/forgot-password`, `/reset-password` |
| Utilisateur (`/me`) | `dashboard`, `onboarding`, `profile`, `mesures-biometriques`, `sommeil`, `seances`, `exercices`, `nutrition`, `nutrition/plats`, `aliments`, `journal-alimentaire`, `analyse-plat`, `recommandations`, `coach-posture`, `objectifs`, `photos`, `historique` |
| Administrateur (`/admin`) | `dashboard`, `utilisateurs`, `etl`, `etl/executions`, `etl/lots`, `etl/compare`, `qualite`, `controles-qualite`, `regles-qualite`, `aliments`, `exercices`, `exports` |
| Super-administrateur (`/super-admin`) | `dashboard`, `organisations`, `sources`, `monitoring` |

Trois parcours structurent l'usage : l'utilisateur passe par `/login` puis, s'il n'a pas terminé son inscription, par `/me/onboarding` avant d'atteindre son tableau de bord et ses recommandations ; l'administrateur va de `/admin/etl` aux exécutions, puis aux contrôles qualité d'un lot ; le super-administrateur consulte le tableau de bord global puis le monitoring.

## 5. Modélisation des données

### Démarche

La modélisation a suivi la méthode Merise, du conceptuel au physique. J'ai produit les premiers diagrammes en février 2026 avec PlantUML, accompagnés d'un dictionnaire de données ; ils ont ensuite été enrichis au fil des MSPR (tables de pilotage ETL en avril, `coach_posture_session` en juin). Les figures ci-dessous sont régénérées avec archify à partir de l'état final de `backend/app/db/models.py`.

*Figure 18 — Modèle conceptuel de données (`dossier/figures/archify/fig18_mcd.png`, rendu de la page `fig18_mcd.html`).*
*Figure 19 — Modèle logique de données : tables métier (archify, `dossier/figures/archify/fig19a_mld_metier.png`) et tables de pilotage ETL (`dossier/figures/archify/fig19b_mld_pilotage_etl.png`).*
*Figure 20 — Modèle physique de données : tables métier (archify, `dossier/figures/archify/fig20a_mpd_metier.png`) et tables de pilotage ETL (`dossier/figures/archify/fig20b_mpd_pilotage_etl.png`).*

### Les 20 tables

Le schéma compte 20 tables dans sa version courante (19 à la première livraison, `coach_posture_session` ayant été ajoutée en juin), réparties en deux domaines.

**Domaine métier (13 tables)**

| Table | Rôle | Liens |
|---|---|---|
| `organisation` | Client B2B ; support du cloisonnement des données | — |
| `utilisateur` | Compte, profil déclaratif (allergies, équipements, contraintes de santé, préférences en JSON), rôle, statut, mot de passe haché | → `organisation` |
| `objectif_utilisateur` | Objectif en cours (perte de poids, gain musculaire, sommeil…), un seul actif à la fois (`actif_unique`) | → `utilisateur` |
| `progression_photo` | Photo avant/après rattachée à un objectif | → `utilisateur`, `objectif_utilisateur` |
| `mesure_biometrique` | Poids, taille, IMC, masse grasse, fréquences cardiaques, hydratation | → `utilisateur`, `source_donnees`, `lot_donnees` |
| `mesure_sommeil_sante` | Durée et qualité de sommeil, stress, tension systolique/diastolique, pas, troubles du sommeil | → `utilisateur`, `source_donnees`, `lot_donnees` |
| `exercice` | Catalogue d'exercices avec parties du corps, muscles, équipement, instructions et animations GIF en quatre résolutions | → `source_donnees` |
| `seance_entrainement` | Séance datée : type, durée, calories, niveau | → `utilisateur`, `source_donnees`, `lot_donnees` |
| `seance_exercice` | Détail d'une séance : exercice, ordre, séries, répétitions, charge | → `seance_entrainement`, `exercice` |
| `coach_posture_session` | Session de coach posture : exercice, score d'alignement, répétitions, temps de maintien | → `utilisateur` |
| `aliment` | Référentiel nutritionnel : calories et macronutriments pour 100 g | → `source_donnees` |
| `plat` | Repas consommé, daté et typé | → `utilisateur`, `source_donnees`, `lot_donnees` |
| `journal_alimentaire` | Ligne de consommation : aliment du référentiel ou saisie libre, quantité, calories | → `utilisateur`, `plat`, `aliment`, `source_donnees`, `lot_donnees` |

**Domaine de pilotage ETL (7 tables)**

| Table | Rôle | Liens |
|---|---|---|
| `source_donnees` | Source d'import (nom, type, format, actif) | — |
| `execution_etl` | Une exécution du pipeline pour une source : compteurs de lignes lues, valides, invalides, doublons, taux de qualité | → `source_donnees` |
| `lot_donnees` | Lot produit par une exécution ; porte le statut de validation et le validateur | → `execution_etl`, `source_donnees`, `utilisateur` |
| `enregistrement_brut` | Ligne source conservée telle quelle en JSON | → `lot_donnees` |
| `stg_import` | Ligne normalisée en JSON, avec son statut de validation et le code de rejet potentiel | → `lot_donnees` |
| `regle_qualite` | Règle déclarative : entité, champ, type de contrôle, sévérité | — |
| `controle_qualite_donnee` | Résultat d'un contrôle sur une ligne : valeur observée, valeur corrigée, décision, étape du pipeline | → `execution_etl`, `lot_donnees`, `regle_qualite` |

### Règles de gestion et choix de normalisation

- Un utilisateur appartient à une organisation ; un administrateur ne voit que les utilisateurs de la sienne.
- Une séance contient plusieurs exercices, ordonnés ; la table de liaison `seance_exercice` porte les attributs propres à cette occurrence (séries, charge). C'est la troisième forme normale : ces attributs ne dépendent ni de la séance seule ni de l'exercice seul. Une contrainte d'unicité `(seance_id, ordre_exercice, exercice_id)` interdit deux fois le même exercice au même rang.
- Toute mesure ou consommation importée référence sa source et son lot, ce qui permet de remonter d'une valeur affichée jusqu'à la ligne du fichier CSV d'origine.
- Un seul objectif actif par utilisateur : la colonne `actif_unique` est indexée avec `utilisateur_id`, et l'application vérifie l'unicité avant insertion.
- Les colonnes `*_json` de `utilisateur` (allergies, équipements, contraintes) sont une dénormalisation assumée : ces listes courtes et ouvertes servent uniquement en entrée du moteur de recommandations, jamais en critère de jointure. Les mettre en tables dédiées aurait ajouté six tables sans requête pour les justifier.
- Les identifiants externes des jeux de données (`gym_external_id`, `sleep_external_id`, `external_id` des exercices) sont conservés avec une contrainte d'unicité : c'est ce qui rend les imports rejouables sans doublon.

### Choix physiques

Le schéma physique a été écrit à la main en SQL, puis reflété dans les modèles SQLAlchemy ; le script est la référence, l'ORM doit s'y conformer. Quatre décisions le caractérisent.

**Types stricts.** Les identifiants sont des `BIGINT UNSIGNED`, les mesures des `DECIMAL(8,2)` ou `DECIMAL(6,2)` (jamais `FLOAT`, dont l'arrondi rendrait deux imports identiques différents), les compteurs des `SMALLINT UNSIGNED`. Les domaines fermés sont des `ENUM` : `genre`, `role`, `statut` de l'utilisateur, `type_objectif`, `type_repas`, statuts d'exécution et de lot, niveaux et décisions des contrôles qualité. L'ENUM refuse une valeur hors liste au niveau de la base, quel que soit le code qui écrit.

**Index composés pour les requêtes réelles.** Le sujet de la première MSPR signalait que les étudiants « sous-estiment souvent les index composés nécessaires ». Chaque table d'historique porte un index `(utilisateur_id, date)` : `idx_mesure_bio_utilisateur_date`, `idx_mesure_sommeil_utilisateur_date`, `idx_seance_utilisateur_date`, `idx_plat_utilisateur_date`, `idx_journal_utilisateur_date`. C'est la forme exacte des requêtes du tableau de bord (« les mesures de cet utilisateur sur les 30 derniers jours ») et du moteur de recommandations (« la dernière mesure de cet utilisateur »). Les tables de pilotage ETL sont indexées sur `(lot_id, entite)` et `(execution_id, niveau)`, qui sont les filtres de l'espace administrateur. Au total, 57 index et 10 contraintes d'unicité.

**Politiques d'intégrité référentielle explicites.** Sur les 35 clés étrangères, 12 sont en `ON DELETE CASCADE` et 20 en `ON DELETE SET NULL`. La règle : ce qui appartient à un utilisateur disparaît avec lui (mesures, séances, repas, objectifs, photos) — c'est le droit à l'effacement du RGPD, appliqué par la base ; ce qui n'est qu'une provenance (source, lot, organisation) est mis à `NULL`, pour ne pas perdre une mesure parce qu'un lot d'import a été purgé.

**Horodatage par défaut.** `cree_le` vaut `current_timestamp()` et `modifie_le` est mis à jour par `ON UPDATE current_timestamp()` : l'audit ne dépend pas de la discipline du code applicatif.

### Volumes de la base livrée

L'export de la base à la première soutenance (25 avril 2026) donne l'ordre de grandeur des données réellement chargées par le pipeline ETL :

| Table | Lignes | Table | Lignes |
|---|---|---|---|
| `seance_exercice` | 2 850 | `aliment` | 593 |
| `enregistrement_brut` / `stg_import` | 2 028 chacune | `mesure_sommeil_sante` | 374 |
| `utilisateur` | 986 | `plat` | 321 |
| `objectif_utilisateur` | 973 | `controle_qualite_donnee` | 47 |
| `mesure_biometrique` | 950 | `exercice` | 30 |
| `seance_entrainement` | 950 | `regle_qualite` | 15 |
| `journal_alimentaire` | 651 | `execution_etl`, `lot_donnees`, `source_donnees`, `organisation` | 5 chacune |

Les 2 028 lignes brutes correspondent aux 2 028 lignes normalisées : aucune ligne source n'est perdue entre l'extraction et le staging, ce que garantit la traçabilité par lot.

### Script de création et versionnement

Le schéma est livré en deux fichiers dans `backend/db/`, décrits en annexe A :

- `schema_v1_2026-04-25.sql` : les 19 tables de la première livraison, export de la base réelle, données retirées et compteurs remis à zéro (31 Ko).
- `migration_v2_2026-06.sql` : les évolutions de juin — quinze colonnes de profil déclaratif et d'onboarding sur `utilisateur`, poids cible et statut sur `objectif_utilisateur`, table `coach_posture_session`. Chaque instruction utilise `IF NOT EXISTS`, le script est rejouable.

Un troisième fichier, `schema_from_orm_reference.sql`, est généré depuis `models.py` et sert uniquement à contrôler que l'ORM n'a pas dérivé du schéma : la comparaison colonne par colonne des 20 tables est reproduite en annexe A. Elle a révélé une colonne `expression_regle` présente en base et absente du modèle, sans usage dans le code — à supprimer dans une prochaine migration.

**Extrait 4 — `backend/db/schema_v1_2026-04-25.sql`, table `utilisateur` (v1) et table de liaison `seance_exercice`**

```sql
CREATE TABLE `utilisateur` (
  `utilisateur_id` bigint(20) UNSIGNED NOT NULL,
  `organisation_id` bigint(20) UNSIGNED DEFAULT NULL,
  `gym_external_id` varchar(120) DEFAULT NULL,
  `sleep_external_id` varchar(120) DEFAULT NULL,
  `nom_utilisateur` varchar(120) NOT NULL,
  `prenom` varchar(120) DEFAULT NULL,
  `nom` varchar(120) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `date_naissance` date DEFAULT NULL,
  `genre` enum('Homme','Femme','Autre','Inconnu') NOT NULL DEFAULT 'Inconnu',
  `taille_cm` decimal(6,2) DEFAULT NULL,
  `role` enum('UTILISATEUR','ADMIN','SUPER_ADMIN') NOT NULL DEFAULT 'UTILISATEUR',
  `statut` enum('ACTIF','INACTIF','SUSPENDU') NOT NULL DEFAULT 'ACTIF',
  `mot_de_passe_hash` varchar(255) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp(),
  `modifie_le` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `utilisateur`
  ADD PRIMARY KEY (`utilisateur_id`),
  ADD UNIQUE KEY `uq_utilisateur_nom_utilisateur` (`nom_utilisateur`),
  ADD UNIQUE KEY `uq_utilisateur_email` (`email`),
  ADD UNIQUE KEY `uq_utilisateur_gym_external_id` (`gym_external_id`),
  ADD UNIQUE KEY `uq_utilisateur_sleep_external_id` (`sleep_external_id`),
  ADD KEY `idx_utilisateur_organisation` (`organisation_id`),
  ADD KEY `idx_utilisateur_role_statut` (`role`,`statut`),
  ADD CONSTRAINT `fk_utilisateur_organisation` FOREIGN KEY (`organisation_id`)
    REFERENCES `organisation` (`organisation_id`) ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE `seance_exercice` (
  `seance_exercice_id` bigint(20) UNSIGNED NOT NULL,
  `seance_id` bigint(20) UNSIGNED NOT NULL,
  `exercice_id` bigint(20) UNSIGNED NOT NULL,
  `ordre_exercice` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `series_nb` int(10) UNSIGNED DEFAULT NULL,
  `repetitions_nb` int(10) UNSIGNED DEFAULT NULL,
  `charge_kg` decimal(8,2) DEFAULT NULL,
  `duree_min` decimal(8,2) DEFAULT NULL,
  `calories_brulees_estimees` decimal(10,2) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `seance_exercice`
  ADD PRIMARY KEY (`seance_exercice_id`),
  ADD UNIQUE KEY `uq_seance_exercice_ordre` (`seance_id`,`ordre_exercice`,`exercice_id`),
  ADD CONSTRAINT `fk_seance_exercice_seance` FOREIGN KEY (`seance_id`)
    REFERENCES `seance_entrainement` (`seance_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seance_exercice_exercice` FOREIGN KEY (`exercice_id`)
    REFERENCES `exercice` (`exercice_id`) ON UPDATE CASCADE;
```

Pourquoi ce choix : le mot de passe n'est jamais stocké en clair ; l'unicité de l'email, du nom d'utilisateur et des identifiants externes est garantie par la base et non par l'application ; l'index `(role, statut)` sert la liste des utilisateurs de l'espace administrateur, filtrée par ces deux colonnes. Sur `seance_exercice`, supprimer une séance supprime ses lignes (`CASCADE`), mais supprimer un exercice du catalogue est refusé tant qu'une séance l'utilise (pas de politique `ON DELETE`, donc `RESTRICT`) : on ne fait pas disparaître l'historique d'un utilisateur en nettoyant un référentiel.

**Extrait 4 bis — `backend/db/migration_v2_2026-06.sql`, évolution rejouable**

```sql
ALTER TABLE `utilisateur`
  ADD COLUMN IF NOT EXISTS `allergies_json`         text DEFAULT NULL COMMENT 'liste JSON, ex. ["arachide"]',
  ADD COLUMN IF NOT EXISTS `equipements_json`       text DEFAULT NULL COMMENT 'liste JSON, ex. ["halteres","tapis"]',
  ADD COLUMN IF NOT EXISTS `contraintes_sante_json` text DEFAULT NULL COMMENT 'liste JSON, ex. ["douleur genou"]',
  ADD COLUMN IF NOT EXISTS `onboarding_complete`    tinyint(1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `onboarding_complete_le` datetime DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `coach_posture_session` (
  `coach_posture_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `utilisateur_id`   bigint(20) UNSIGNED NOT NULL,
  `exercice_code`    varchar(80) NOT NULL,
  `type_exercice`    varchar(20) NOT NULL COMMENT 'dynamic | static',
  `score_alignement` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `reps`             int(10) UNSIGNED NOT NULL DEFAULT 0,
  `valide_le`        datetime NOT NULL,
  PRIMARY KEY (`coach_posture_id`),
  KEY `idx_coach_posture_utilisateur_date` (`utilisateur_id`,`valide_le`),
  CONSTRAINT `fk_coach_posture_utilisateur` FOREIGN KEY (`utilisateur_id`)
    REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

Pourquoi ce choix : le projet n'a pas d'outil de migration dans la version de référence (Alembic avait été introduit dans la branche d'intégration de juin, non fusionnée). Un script SQL versionné, daté et rejouable est la réponse minimale et suffisante : il documente ce qui a changé et pourquoi, et il s'applique sur une base v1 sans perte de données. La nouvelle table suit les mêmes conventions que la v1 : identifiant `BIGINT UNSIGNED`, index `(utilisateur_id, date)`, suppression en cascade avec l'utilisateur.

## 6. Diagramme de cas d'utilisation

*Figure 22 — Cas d'utilisation (archify, `dossier/figures/archify/fig22_cas_utilisation.png`, source `dossier/figures/sources/cas_utilisation.mmd`).*

Trois acteurs, le super-administrateur héritant des droits de l'administrateur, qui hérite de ceux de l'utilisateur. Les cas sont regroupés en cinq paquets :

| Paquet | Cas d'utilisation | Acteur |
|---|---|---|
| Compte | S'inscrire, se connecter, réinitialiser son mot de passe, compléter son profil (onboarding) | Utilisateur |
| Suivi santé | Saisir une mesure biométrique, une nuit de sommeil, une séance, un repas ; consulter son tableau de bord et son historique | Utilisateur |
| Coaching IA | Obtenir des recommandations, analyser une photo de repas, lancer une session de coach posture, enregistrer une séance recommandée, donner un retour sur une recommandation | Utilisateur |
| Administration des données | Lancer une exécution ETL, consulter les lots et les contrôles qualité, gérer les règles de qualité, gérer le référentiel d'aliments et d'exercices, exporter | Administrateur |
| Supervision | Gérer les organisations et les sources, consulter le monitoring global | Super-administrateur |

Tous les cas, sauf l'inscription et la réinitialisation, incluent « S'authentifier ».

## 7. Diagrammes de séquence

Deux séquences ont été retenues parce qu'elles traversent toutes les couches et illustrent les deux propriétés attendues par le cahier des charges : la résilience et la sécurité.

### Analyse d'une photo de repas

*Figure 23 — Séquence d'analyse d'un repas par photo (archify, `dossier/figures/archify/fig23_sequence_analyse_repas.png`).*

1. Le composant `MealAnalysis` du frontend envoie l'image en `multipart/form-data` à `POST /api/ai/analyse-repas`, avec le jeton d'accès dans l'en-tête `Authorization`.
2. La route (`modules/ai_features.py`) vérifie le jeton via la dépendance `current_user`, lit l'image et rejette au-delà de 10 Mo (413).
3. Elle instancie `GeminiVisionService`. Si aucune clé n'est configurée, l'appel est journalisé dans `ai_provider_calls` avec le statut `unavailable` et l'API répond 503 avec un message explicite ; le frontend affiche l'état « service non configuré ».
4. Sinon, `analyze()` envoie l'image à Gemini 2.5 Flash avec une consigne de réponse en JSON, puis nettoie la réponse. Une exception est journalisée puis relevée ; une liste vide (erreur HTTP, JSON invalide, délai dépassé) est journalisée avec le statut `fallback`.
5. Le résultat est enregistré dans `food_analyses` via `document_store.save_meal_analysis`. Si MongoDB est indisponible, l'écriture est ignorée et l'utilisateur reçoit quand même sa réponse.
6. La réponse `MealAnalysisResponse` (aliments détectés, macronutriments estimés) est renvoyée au frontend.

### Authentification et contrôle d'accès

*Figure 24 — Séquence d'authentification et de rafraîchissement du jeton (archify, `dossier/figures/archify/fig24_sequence_authentification.png`).*

1. `POST /api/auth/login` est limité à dix appels par minute et par adresse (`@limiter.limit("10/minute")`). Les identifiants sont vérifiés par `authenticate_user` ; le mot de passe est comparé au condensé PBKDF2 en temps constant.
2. En cas de succès, deux jetons sont émis : un jeton d'accès de 30 minutes renvoyé dans le corps et conservé en mémoire par le frontend, et un jeton de rafraîchissement de 7 jours posé dans un cookie `HttpOnly`, `SameSite=Strict`.
3. Chaque appel protégé passe par `current_user`, qui décode le jeton, charge l'utilisateur et vérifie que son statut est `ACTIF`. Les routes d'administration ajoutent `require_roles("ADMIN")` ou `require_roles("SUPER_ADMIN")`, qui répond 403 si le rôle est insuffisant.
4. Quand un appel reçoit 401, le client (`frontend/src/lib/api.ts`) appelle `POST /api/auth/refresh` une seule fois, même si plusieurs requêtes échouent en même temps : une promesse partagée `refreshPromise` sérialise les tentatives. La requête initiale est rejouée avec le nouveau jeton ; si le rafraîchissement échoue, l'utilisateur est renvoyé vers `/login`.

Ces deux diagrammes sont repris tels quels dans le support de soutenance.
