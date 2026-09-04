# I. Pages liminaires

## Page de garde (p. 1)

```
[Logo EPSI — asset à récupérer]                      [Logo HealthAI Coaching — à créer]

                        DOSSIER PROJET

                     HealthAI Coaching
      Plateforme de suivi santé, sport et nutrition assistée par IA

        Titre professionnel Concepteur Développeur d'Applications
                    Niveau 6 — RNCP 37873

                        Hicham Benamara
                    EPSI Courbevoie — Session 2026

   Projet réalisé dans le cadre des mises en situation professionnelle
   reconstituées (MSPR) du programme B3 CDA, en équipe avec Aedh Aljene
   et Maxime Rousson.

   Dépôt de référence : github.com/aedh2/mspr2_version_aedh-Public (branche maintenance)
```

## Sommaire (p. 2)

Table des matières générée par Word, deux niveaux. Ne pas la rédiger à la main.

## Remerciements (p. 3)

Je remercie l'équipe pédagogique de l'EPSI Courbevoie pour l'encadrement des trois mises en situation professionnelle qui ont donné naissance à ce projet, ainsi que les jurys qui les ont évaluées et dont les retours ont orienté les évolutions présentées ici.

Je remercie Aedh Aljene et Maxime Rousson, avec qui j'ai construit HealthAI Coaching de décembre 2025 à juillet 2026. Ce dossier décrit un travail collectif ; j'y précise à chaque fois la part qui a été la mienne.

Je remercie enfin les membres du jury de certification pour le temps consacré à la lecture de ce dossier.

## Liste des compétences mises en œuvre (p. 4-5)

Le tableau ci-dessous relie chaque compétence du référentiel RNCP 37873 aux éléments du projet qui la démontrent et aux pages du dossier où ils sont décrits. Les numéros de page seront fixés après la mise en page finale.

| Bloc | Compétence | Ce qui le prouve dans HealthAI Coaching | Pages |
|---|---|---|---|
| 1 | **C1** Installer et configurer son environnement de travail en fonction du projet | Docker Compose à cinq services (MariaDB, MongoDB, backend, frontend, ETL) plus une pile de supervision séparée ; fichier `.env.example` ; `Makefile` d'exploitation ; conventions Git (branches de fonctionnalité, commits conventionnels) | V, VII |
| 1 | **C2** Développer des interfaces utilisateur | Frontend Next.js 16 avec trois espaces par rôle (`/me`, `/admin`, `/super-admin`), 34 routes, composants partagés (`data-table`, `pagination`, `states`), graphiques Recharts, garde de rôle côté client | VIII |
| 1 | **C3** Développer des composants métier | Moteur de recommandations à règles (`services/recommendations.py`), analyse de repas avec repli entre fournisseurs (`services/meal_analysis.py`), services LLM (`services/ai_enhanced.py`), contrôles qualité de l'ETL | VIII |
| 1 | **C4** Contribuer à la gestion d'un projet informatique | Trois lots de livraison alignés sur les MSPR, répartition par périmètre, points d'avancement, relecture croisée, matrice des risques | V |
| 2 | **C5** Analyser les besoins et maquetter une application | Cahier des charges HealthAI Coach, personas, tableau d'exigences par rôle, maquettes des écrans principaux, diagramme de navigation | IV, VI |
| 2 | **C6** Définir l'architecture logicielle d'une application | Architecture en couches du backend (routes → services → accès aux données), persistance polyglotte, module IA avec repli, décision NestJS → FastAPI documentée | VI, VII |
| 2 | **C7** Concevoir et mettre en place une base de données relationnelle | 20 tables MariaDB (13 métier, 7 de pilotage ETL), MCD/MLD/MPD, dictionnaire de données, scripts SQL versionnés (`schema_v1`, `migration_v2`), 57 index dont 16 composés, 35 clés étrangères avec politiques explicites | VI, annexe A |
| 2 | **C8** Développer des composants d'accès aux données SQL et NoSQL | SQLAlchemy 2.0 avec CRUD générique et pagination (`modules/resources.py`, `core/pagination.py`) ; PyMongo avec quatre collections et mode dégradé (`db/mongo.py`, `services/document_store.py`) | VIII |
| 3 | **C9** Préparer et exécuter les plans de tests d'une application | Plan de tests, 64 tests automatisés (contrats API, règles métier, sécurité, ETL, 4 tests de bout en bout Playwright) exécutés en CI avec lint, tests manuels tracés, jeu d'essai du moteur de recommandations | IX |
| 3 | **C10** Préparer et documenter le déploiement d'une application | Procédure d'installation, `docs/MAINTENANCE.md`, scripts `backup.sh` / `restore.sh`, tableau des services et des ports, endpoint `/health` | X |
| 3 | **C11** Contribuer à la mise en production dans une démarche DevOps | Pipeline GitHub Actions (tests backend + build frontend), métriques Prometheus exposées par l'API, tableau de bord Grafana, correctifs de maintenance tracés par commit | X |

Deux compétences appellent une remarque. La C5 s'appuie sur des maquettes réalisées après le développement des écrans, pour les besoins de ce dossier ; le projet a été mené en partant du cahier des charges et des jeux de données, sans phase de maquettage formelle. La C11 couvre l'intégration continue et la supervision ; le déploiement continu vers un serveur n'a pas été mis en place, ce qui est expliqué en section X.
