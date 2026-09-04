# Dossier projet — HealthAI Coaching

**Titre professionnel Concepteur Développeur d'Applications — RNCP 37873**  
Hicham Benamara · EPSI Courbevoie · Session 2026  
Dépôt de référence : `github.com/aedh2/mspr2_version_aedh-Public`, branche `maintenance`

> Version de travail assemblée le 3 septembre 2026 (fin de Phase 2). Les mentions *Figure n — …* désignent les illustrations à insérer ; toutes les figures archify et captures Playwright sont produites dans `dossier/figures/` (chemin indiqué dans chaque légende) ; restent la figure 29 (capture MongoDB Compass) et les tableaux Word. La mise en forme Word (Phase 4) et l'humanisation (Phase 3) restent à faire.

## Sommaire

- I. Pages liminaires
  - Page de garde (p. 1)
  - Sommaire (p. 2)
  - Remerciements (p. 3)
  - Liste des compétences mises en œuvre (p. 4-5)
- II. Présentation du contexte et du cadre du projet
  - 1. Le cadre de formation
  - 2. Le commanditaire
  - 3. L'équipe et mon rôle
  - 4. Une décision de conception à retenir
  - 5. Ce que le lecteur trouvera dans la suite
- III. Project summary (English)
- IV. Cahier des charges — expression des besoins
  - 1. Contexte et problématique
  - 2. Objectifs
  - 3. Utilisateurs cibles
  - 4. Besoins fonctionnels par rôle
  - 5. Contraintes et livrables attendus par le commanditaire
- V. Gestion de projet
  - 1. Méthode
  - 2. Planning réalisé et suivi
  - 3. Environnement humain
  - 4. Environnement de travail
  - 5. Objectifs de qualité
  - 6. Matrice des risques
- VI. Spécifications fonctionnelles
  - 1. Contraintes et livrables
  - 2. Architecture logicielle
  - 3. Charte graphique
  - 4. Maquettage
  - 5. Modélisation des données
  - 6. Diagramme de cas d'utilisation
  - 7. Diagrammes de séquence
- VII. Spécifications techniques
  - 1. Choix techniques et alternatives étudiées
  - 2. Environnements
  - 3. Spécifications de sécurité
- VIII. Réalisations
  - 1. Interfaces utilisateur
  - 2. Composants métier
  - 3. Composants d'accès aux données SQL et NoSQL
  - 4. Autres composants
  - 5. Éléments de sécurité
- IX. Tests
  - 1. Stratégie et plan de tests
  - 2. Tests automatisés
  - 3. Tests manuels de bout en bout
  - 4. Jeu d'essai du moteur de recommandations
- X. Déploiement et démarche DevOps
  - 1. Documentation de déploiement
- Sauvegarde des bases HealthAI Coach (MariaDB + MongoDB) depuis les conteneurs Docker.
  - 2. Intégration continue
  - 3. Supervision
  - 4. Maintenance
- XI. Veille sur les vulnérabilités de sécurité
  - 1. Organisation de la veille
  - 2. État des dépendances au 2 septembre 2026
  - 3. Décisions issues de la veille pendant le projet
  - 4. Veille réglementaire et éthique
  - 5. Vulnérabilités anticipées
- XII. Conclusion
  - Ce que le projet a livré
  - Ce dont je suis satisfait
  - Ce qui m'a coûté
  - Ce que je ferais différemment
  - Perspectives
  - Ce que le projet m'a appris
- XIII. Annexes (≤ 40 pages)
- Annexe A — Scripts de base de données et contrôle de cohérence

---

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

---

# II. Présentation du contexte et du cadre du projet

## 1. Le cadre de formation

Ce projet a été réalisé au cours de la troisième année du programme Concepteur Développeur d'Applications de l'EPSI Courbevoie, entre décembre 2025 et juillet 2026. L'EPSI évalue ses apprenants par des mises en situation professionnelle reconstituées (MSPR) : un cahier des charges fictif mais réaliste est remis à une équipe de trois ou quatre étudiants, qui doit livrer une solution fonctionnelle, sa documentation et la présenter devant un jury de professionnels extérieurs à l'école.

HealthAI Coaching a servi de fil conducteur à trois MSPR successives, chacune couvrant un bloc de compétences différent. La même base de code a été enrichie d'une soutenance à l'autre, ce qui explique la forme du projet : un socle données et API, puis une couche d'intelligence artificielle, puis l'outillage de production. Les trois soutenances ont été validées.

| MSPR | Bloc évalué | Période | Soutenance | Apport principal |
|---|---|---|---|---|
| TPRE501 | Créer un modèle de données d'une solution IA | déc. 2025 → avr. 2026 | 30 avril 2026 | Pipeline ETL, base MariaDB, API FastAPI, frontend Next.js |
| TPRE502 | Développer un modèle prédictif d'une solution IA | juin 2026 | 29 juin 2026 | Analyse de repas par vision, recommandations par LLM, coach posture, MongoDB |
| TPRE601/604 | Produire et maintenir une solution IA | 24 juin → 2 juil. 2026 | 3 juillet 2026 | Intégration continue, supervision Prometheus/Grafana, sauvegarde et restauration, mode dégradé |

*Figure 2 — Frise chronologique du projet : trois jalons MSPR et principaux repères Git (archify, `dossier/figures/archify/fig02_frise_chronologique.png`).*

## 2. Le commanditaire

HealthAI Coach est une startup fictive décrite dans le cahier des charges de la première MSPR. Elle se positionne sur la santé connectée avec un modèle freemium (suivi de base gratuit, recommandations IA en abonnement) et une offre B2B en marque blanche destinée aux salles de sport, mutuelles et entreprises. Cette offre B2B justifie un point de conception qui structure toute l'application : les utilisateurs sont rattachés à une organisation, et un administrateur ne voit que les données de la sienne.

Le sujet fixait aussi des ordres de grandeur : 50 000 utilisateurs cibles, 200 000 entrées nutritionnelles et 150 000 sessions d'exercice par jour. Nous n'avons évidemment pas atteint ces volumes en formation, mais ils ont orienté des choix concrets : pagination systématique des listes, index sur les colonnes filtrées, traçabilité des imports lot par lot.

Le formateur référent de chaque MSPR tenait le rôle du client. Les jurys de soutenance, composés de professionnels, jouaient celui du public technique auquel on livre le produit.

## 3. L'équipe et mon rôle

L'équipe comptait trois personnes : Aedh Aljene, Maxime Rousson et moi-même. Un quatrième camarade a créé le dépôt initial en décembre 2025 et réalisé l'import du projet en juin, sans participer au développement.

Le travail a été réparti par périmètre plutôt que par fonctionnalité, ce qui a permis à chacun de rester maître d'une partie de la chaîne :

| Périmètre | Responsable principal | Contributions des autres |
|---|---|---|
| Modélisation des données, base relationnelle | Hicham Benamara | relecture |
| Pipeline ETL et contrôles qualité | Aedh Aljene | Hicham Benamara (structure, conteneur ETL, seed) |
| Backend FastAPI, sécurité | Hicham Benamara (socle initial, durcissement de juin) | Maxime Rousson (évolutions de juillet) |
| Frontend Next.js | Maxime Rousson | Aedh Aljene (recommandations, intégration) |
| Services IA (vision, LLM, coach posture) | Maxime Rousson, Aedh Aljene | Hicham Benamara (intégration, proxy sécurisé) |
| Conteneurisation, CI, supervision, sauvegardes | Hicham Benamara (Docker, seed), Maxime Rousson (CI, monitoring, backup) | — |
| Veille, conformité RGPD, déploiement | Hicham Benamara | — |

Ma contribution se lit dans l'historique Git des dépôts successifs. En février 2026, j'ai produit les diagrammes Merise (MCD, MLD, MPD) et le dictionnaire de données, puis le premier backend FastAPI : SQLAlchemy 2.0, migrations, CRUD utilisateurs, aliments et exercices, journal d'audit, documentation OpenAPI. En avril, j'ai assemblé la version livrée pour la première soutenance : Docker Compose, Dockerfiles, réorganisation du pipeline ETL, alimentation de la base. En juin, j'ai intégré le service d'analyse d'images comme micro-service, écrit la route de proxy sécurisée, durci la configuration (secrets, JWT, CORS) et ajouté les tests de sécurité et le premier workflow d'intégration continue.

La version de référence de ce dossier est la branche `maintenance` du dépôt public, telle que présentée à la troisième soutenance. Ses derniers commits portent le nom de Maxime Rousson ; j'y ai contribué en relecture, en tests et en intégration. Lorsque cette version diffère de ce que j'avais mis en place en juin (bibliothèque JWT, contrôle des secrets), je le signale, et la section XI montre comment ces écarts ont été traités.

## 4. Une décision de conception à retenir

Le 26 avril 2026, à trois jours de la première soutenance, j'ai réécrit le backend en NestJS avec Prisma, en cinq lots fonctionnels. Le lendemain, l'équipe a décidé de revenir à FastAPI. Les raisons tiennent en quatre points : le pipeline ETL était déjà en Python et les modules d'IA allaient l'être, ce qui donnait une seule chaîne d'outils du chargement des données jusqu'aux appels de modèles ; un socle FastAPI avec SQLAlchemy existait depuis février et avait déjà été testé ; FastAPI génère la documentation OpenAPI depuis les schémas Pydantic sans annotation supplémentaire, alors que le sujet en faisait une exigence ; enfin, Prisma cible MySQL et demandait de retoucher à la main les migrations générées pour MariaDB.

Cette journée perdue a été le bon prix à payer : elle a réglé une fois pour toutes la question du langage serveur, et c'est ce choix qui a permis en juin d'ajouter le module IA sans changer de pile.

## 5. Ce que le lecteur trouvera dans la suite

Les sections IV et V décrivent le besoin et la conduite du projet. Les sections VI à VIII détaillent la conception et la réalisation, avec les extraits de code les plus significatifs et les raisons de chaque choix. La section IX présente les tests et le jeu d'essai du moteur de recommandations. Les sections X et XI couvrent le déploiement, la supervision et la veille sur les vulnérabilités. Les annexes contiennent le script de création de la base, les fichiers de configuration et les captures complémentaires.

---

# III. Project summary (English)

HealthAI Coaching is a health, fitness and nutrition tracking platform built by a team of three students at EPSI Courbevoie between December 2025 and July 2026, across three professional simulations (MSPR) that were all validated by external juries. The fictional client, a health-tech start-up, needed to consolidate heterogeneous data sources — body measurements, sleep, workouts and meals from several Kaggle datasets and an exercise catalogue — into a reliable database, and to turn that data into personalised recommendations.

The solution is a layered web application. A Python ETL pipeline loads the sources into a MariaDB database of twenty tables, keeping the raw and normalised version of every row and recording every quality decision against fifteen declarative rules. A FastAPI back end exposes a role-based REST API (user, administrator, super-administrator) documented with OpenAPI, secured with hashed passwords, short-lived JWT access tokens and an HttpOnly refresh cookie. A Next.js 15 front end provides three workspaces: personal dashboards and coaching for users, ETL and data-quality management for administrators, and multi-organisation monitoring for super-administrators.

The AI layer combines a deterministic rules engine — which excludes foods and exercises according to allergies, available equipment and health constraints, and explains each exclusion — with a local language model (Llama via Ollama) that selects exercises from the filtered catalogue, and a cloud vision model (Gemini 2.5 Flash) for meal photo analysis. AI outputs are stored in MongoDB, and the application keeps working when MongoDB or an AI provider is unavailable. Production tooling includes a GitHub Actions pipeline running thirty-nine automated tests, Prometheus metrics with a Grafana dashboard, and backup and restore scripts covering both databases.

My own contributions were the data model (Merise diagrams and data dictionary), the initial FastAPI back end, containerisation and database seeding, the integration of the AI service, security hardening, security tests and the first continuous-integration workflow, as well as the regulatory, deployment and technology-watch topics presented at the defences. The dossier also documents a real test case run on the recommendation engine, the three deviations it revealed, and the maintenance work derived from dependency audits and security recommendations.

*(About 340 words. To be trimmed to 250 if the school template imposes that limit.)*

---

# IV. Cahier des charges — expression des besoins

## 1. Contexte et problématique

Le point de départ est le sujet de la première MSPR. HealthAI Coach, startup fictive de la santé connectée, veut une plateforme qui centralise les données de ses utilisateurs (mesures corporelles, sommeil, activité physique, alimentation), en garantit la qualité, et en tire des recommandations personnalisées. Le sujet insistait sur un point : les données arrivent de sources hétérogènes, avec leurs unités, leurs formats et leurs erreurs, et l'application ne vaut que si elle sait les rendre fiables avant de les exploiter.

Le contexte chiffré (50 000 utilisateurs, 200 000 entrées nutritionnelles et 150 000 sessions d'exercice par jour) n'était pas une cible à atteindre en formation mais une contrainte de conception : tout ce qui est écrit doit pouvoir passer à cette échelle sans être réécrit.

Les deux MSPR suivantes ont étendu le besoin : produire des recommandations par une API d'intelligence artificielle, avec un moteur multicritères et une persistance mixte SQL et NoSQL, puis outiller la mise en production (intégration continue, supervision, sauvegarde, tolérance aux pannes).

Un cadre réglementaire s'ajoute à ces demandes : l'application traite des données de santé au sens de l'article 9 du RGPD, et le sujet de la première MSPR exigeait une interface conforme au niveau AA du RGAA. Ces deux points sont traités en sections VI et VII.

## 2. Objectifs

### Objectifs fonctionnels

| # | Objectif | Mesure de réussite |
|---|---|---|
| OF1 | Importer les jeux de données sources dans une base unifiée, avec traçabilité de chaque ligne | 100 % des lignes lues retrouvables en brut et en normalisé ; taux de qualité calculé par exécution |
| OF2 | Permettre à un utilisateur de suivre ses mesures, son sommeil, ses séances et son alimentation | Saisie et consultation sur les six domaines, historique et graphiques d'évolution |
| OF3 | Produire des recommandations sportives et nutritionnelles adaptées au profil et aux contraintes | Réponse en moins de 5 s sans LLM ; exclusions expliquées ; jeu d'essai reproductible |
| OF4 | Analyser une photo de repas et en estimer la composition | Réponse structurée (aliments, macronutriments) ou message explicite si le service est absent |
| OF5 | Donner aux administrateurs le pilotage de la chaîne de données | Exécutions, lots, contrôles qualité et règles consultables et modifiables sans redéploiement |
| OF6 | Permettre la supervision multi-organisations | Tableau de bord global, gestion des organisations et des sources |

### Objectifs non fonctionnels

| # | Objectif | Mesure de réussite |
|---|---|---|
| ONF1 | Sécurité des accès | Trois rôles, jetons courts, mots de passe hachés, cloisonnement par organisation |
| ONF2 | Reproductibilité | Installation complète en moins de 30 minutes avec Docker Compose |
| ONF3 | Résilience | Base documentaire ou fournisseur d'IA absent : l'application reste utilisable |
| ONF4 | Observabilité | Métriques exposées, tableau de bord, journal des appels IA |
| ONF5 | Souveraineté des données de santé | Traitement des profils par un modèle local ; cloud optionnel et limité aux images |
| ONF6 | Accessibilité et sobriété | Points RGAA appliqués sur les écrans principaux ; pagination, modèle léger |

### Périmètre exclu

Le périmètre exclu est aussi important que le périmètre couvert : il dit ce que l'équipe a choisi de ne pas faire et pourquoi.

- **Modèle d'apprentissage entraîné par l'équipe.** La MSPR Bloc 2 attendait un modèle prédictif ; nous avons choisi d'assembler des modèles existants (Gemini, Llama via Ollama, MediaPipe) derrière un moteur de règles, sans entraînement propre ni métriques d'apprentissage. Le jury l'a relevé et validé comme un écart assumé.
- **Application mobile native et synchronisation avec les objets connectés** (Apple Health, Garmin) : évoquées dès la première soutenance comme perspectives, jamais engagées.
- **Diagnostic médical.** L'application ne pose aucun diagnostic et le dit à l'utilisateur ; elle n'est pas un dispositif médical.
- **Déploiement sur un serveur et hébergement de données de santé (HDS).** L'application tourne sur les machines de l'équipe ; les conditions d'un hébergement réel sont décrites en section XI.
- **Paiement et gestion de l'abonnement** du modèle freemium décrit par le commanditaire.

## 3. Utilisateurs cibles

Trois profils correspondent aux trois rôles de l'application. Ils ont été construits pour ce dossier à partir des usages réellement implémentés ; ce ne sont pas des entretiens utilisateurs.

*Figure 3 — Fiches persona (archify ou tableau Word).*

**Léa, 29 ans, utilisatrice (rôle `UTILISATEUR`).** Elle s'entraîne chez elle avec des haltères et un tapis, veut perdre du poids, a une allergie à l'arachide et un genou fragile. Elle attend des séances qu'elle peut réellement faire, des repas qu'elle peut réellement manger, et une vue simple de sa progression. Ses écrans : onboarding, tableau de bord, recommandations, journal alimentaire, photos.

**Karim, 41 ans, administrateur des données (rôle `ADMIN`).** Il pilote les imports pour son organisation, veut savoir combien de lignes ont été rejetées et pourquoi, et corriger une règle trop stricte sans appeler un développeur. Ses écrans : exécutions ETL, lots, avant/après, contrôles et règles qualité, exports.

**Sophie, super-administratrice (rôle `SUPER_ADMIN`).** Elle gère les organisations clientes et les sources de données, et surveille la plateforme dans son ensemble. Ses écrans : tableau de bord global, organisations, sources, monitoring.

## 4. Besoins fonctionnels par rôle

*Figure 4 — Tableau des exigences (extrait ; le tableau complet est en annexe).*

Priorités MoSCoW : M (indispensable), S (important), C (souhaitable). Statut au 3 juillet 2026.

| ID | Rôle | Besoin | Priorité | Statut |
|---|---|---|---|---|
| EX-U-01 | Utilisateur | S'inscrire, se connecter, réinitialiser son mot de passe | M | Livré |
| EX-U-02 | Utilisateur | Compléter un profil déclaratif (objectif, allergies, équipement, contraintes) à la première connexion | M | Livré |
| EX-U-03 | Utilisateur | Saisir et consulter mesures biométriques, sommeil, séances, repas | M | Livré |
| EX-U-04 | Utilisateur | Tableau de bord avec indicateurs et graphiques d'évolution | M | Livré |
| EX-U-05 | Utilisateur | Obtenir des recommandations sport et nutrition tenant compte des contraintes | M | Livré |
| EX-U-06 | Utilisateur | Enregistrer une séance recommandée dans son historique | S | Livré |
| EX-U-07 | Utilisateur | Analyser une photo de repas | S | Livré (dépend d'une clé Gemini) |
| EX-U-08 | Utilisateur | Session de coach posture avec comptage des répétitions | S | Livré |
| EX-U-09 | Utilisateur | Donner un retour sur une recommandation | C | Livré |
| EX-U-10 | Utilisateur | Photos de progression avant/après liées à un objectif | C | Livré |
| EX-U-11 | Utilisateur | Recevoir des notifications ou rappels | C | Non retenu |
| EX-A-01 | Administrateur | Lancer une exécution ETL et suivre son résultat | M | Livré (lancement en ligne de commande ; suivi dans l'interface) |
| EX-A-02 | Administrateur | Consulter lots, lignes brutes, lignes normalisées et décisions qualité | M | Livré |
| EX-A-03 | Administrateur | Activer, désactiver ou modifier une règle de qualité | S | Livré |
| EX-A-04 | Administrateur | Gérer les référentiels d'aliments et d'exercices | S | Livré |
| EX-A-05 | Administrateur | Exporter les données en CSV | S | Livré |
| EX-A-06 | Administrateur | Gérer les utilisateurs de son organisation | M | Livré |
| EX-A-07 | Administrateur | Téléverser un fichier source depuis l'interface | S | Partiel (fichiers déposés dans `data/`) |
| EX-S-01 | Super-admin | Gérer organisations et sources de données | M | Livré |
| EX-S-02 | Super-admin | Tableau de bord global et monitoring | S | Livré |
| EX-T-01 | Exploitant | Installer la plateforme d'une commande | M | Livré |
| EX-T-02 | Exploitant | Sauvegarder et restaurer les deux bases | M | Livré |
| EX-T-03 | Exploitant | Superviser débit, latence, erreurs | S | Livré |
| EX-T-04 | Exploitant | Déployer automatiquement sur un serveur | S | Non retenu |

Deux lignes méritent un mot. EX-A-01 est livré à moitié : le lancement se fait par `docker compose --profile etl run --rm etl`, pas par un bouton dans l'interface, parce qu'un import long dans une requête HTTP aurait exigé une file de tâches que nous n'avons pas eu le temps de mettre en place ; le suivi, lui, est complet. EX-T-04 est la limite la plus nette du projet, expliquée en section X.

## 5. Contraintes et livrables attendus par le commanditaire

Le sujet de la première MSPR listait des livrables précis, repris par les suivantes :

| Livrable demandé | Réponse dans ce projet |
|---|---|
| Base de données relationnelle documentée (MCD, MLD, MPD, dictionnaire) | Section VI, annexe A |
| Pipeline d'import automatisé avec contrôles qualité et rapport d'exécution | Section VIII, figure 30 |
| API documentée (OpenAPI) et sécurisée | Sections VII et VIII, `/api/docs` |
| Interface d'administration pour utilisateurs non techniques, avec pagination et filtres | Section VIII, captures |
| Tableaux de bord accessibles | Sections VI et VIII |
| Procédure d'installation en moins de 30 minutes | Section X |
| Modèle prédictif ou API d'IA de recommandation, SQL + NoSQL | Sections VI à VIII |
| CI/CD, supervision, sauvegarde, gestion des pannes | Section X |
| Veille technologique, réglementaire et sécurité | Section XI |

---

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

---

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

---

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
| Frontend | Next.js 16 (15 jusqu'au 3 septembre 2026, montée pour l'audit de sécurité), React 19, TypeScript | Vite + React, Angular | Routage par dossier qui reflète les trois rôles, TypeScript de bout en bout, écosystème de composants |
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

---

# VIII. Réalisations

Cette section présente les composants les plus significatifs de l'application, avec le code tel qu'il est dans le dépôt de référence. Chaque extrait indique son fichier, et chaque extrait est suivi des raisons qui ont conduit à l'écrire ainsi. L'ordre suit la trame attendue : interfaces, composants métier, accès aux données, autres composants, sécurité.

## 1. Interfaces utilisateur

### L'écran de recommandations

*Figure 27 — Page `/me/recommandations` : formulaire de contraintes, cartes d'exercices avec animation et calories estimées, bouton d'enregistrement de la séance (capture `dossier/figures/captures/fig27_recommandations_sport.png`).*

La page est écrite dans `frontend/src/features/me/pages/Recommandations.tsx`. Elle charge le profil de l'utilisateur pour préremplir les formulaires, puis envoie une requête de recommandation et affiche le résultat en cartes.

**Extrait 7 — `frontend/src/features/me/pages/Recommandations.tsx`, chargement du profil et appel de l'API**

```tsx
export function RecommandationsPage() {
  const [selectedMode, setSelectedMode] = useState<RecommendationMode | null>(null);
  const [mealForm, setMealForm] = useState<MealFormState>(initialMealForm);
  const [sportForm, setSportForm] = useState<SportFormState>(initialSportForm);
  const [profileLoaded, setProfileLoaded] = useState(false);

  const profile = useQuery({
    queryKey: ["/api/me/profile"],
    queryFn: () => apiRequest<User>("/api/me/profile")
  });

  useEffect(() => {
    if (!profile.data || profileLoaded) return;
    setMealForm(mealFormFromProfile(profile.data));
    setSportForm(sportFormFromProfile(profile.data));
    setProfileLoaded(true);
  }, [profile.data, profileLoaded]);

  const mutation = useMutation({
    mutationFn: async (payload: RecommendationRequest): Promise<RecommendationResponse> => {
      const token = getAuthToken();
      const response = await fetch("/api/ai/recommandations", {
        method: "POST",
        credentials: "include",
        headers: {
          "Content-Type": "application/json",
          ...(token ? { authorization: `Bearer ${token}` } : {})
        },
        body: JSON.stringify(payload)
      });
      if (!response.ok) throw new Error(`Erreur ${response.status}`);
      return response.json();
    }
  });

  if (profile.isLoading) return <LoadingState />;
  if (profile.isError) return <ErrorState message={profile.error.message} onRetry={() => profile.refetch()} />;
  // ...
}
```

Pourquoi ce choix : TanStack Query sépare deux natures d'appel. Le profil est une lecture mise en cache (`useQuery`) : si l'utilisateur revient sur la page, il n'est pas rechargé. La génération de recommandations est une action (`useMutation`) : elle n'est jamais rejouée automatiquement, ce qui compte quand un appel au LLM prend plusieurs secondes. Les trois états `isLoading`, `isError` et données sont rendus par des composants partagés (`LoadingState`, `ErrorState`, `EmptyState` dans `components/ui/states.tsx`), ce qui donne le même comportement sur les 34 écrans. Les types `User`, `RecommendationRequest` et `RecommendationResponse` viennent de `types/domain.ts` et reflètent les schémas Pydantic du backend.

### La garde de rôle

*Figure 28 — Page `/admin/controles-qualite` : tableau filtré et paginé des contrôles (capture Playwright, `dossier/figures/captures/fig28_admin_controles_qualite.png`).*

**Extrait 8 — `frontend/src/components/role-guard.tsx`, intégral**

```tsx
"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { LoadingState } from "@/src/components/ui/states";
import { useAuth } from "@/src/features/auth/auth-provider";
import type { Role } from "@/src/types/domain";

export function RoleGuard({ roles, children }: { roles: Role[]; children: React.ReactNode }) {
  const { user, status } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (status === "anonymous") {
      router.replace("/login");
      return;
    }
    if (status === "authenticated" && (!user || !roles.includes(user.role))) {
      router.replace(user?.role === "UTILISATEUR" ? "/me/dashboard" : "/admin/dashboard");
    }
  }, [roles, router, status, user]);

  if (status === "loading") {
    return <LoadingState label="Verification de la session..." />;
  }

  if (!user || !roles.includes(user.role)) {
    return <LoadingState label="Redirection..." />;
  }

  return <>{children}</>;
}
```

Pourquoi ce choix : chaque espace (`/me`, `/admin`, `/super-admin`) enveloppe ses pages dans `RoleGuard` avec la liste des rôles admis. Un visiteur anonyme est renvoyé vers la connexion ; un utilisateur connecté qui tape une URL d'administration est renvoyé vers son propre tableau de bord. Ce composant ne protège rien à lui seul, et c'est voulu : l'API refuse de toute façon les appels sans le bon rôle (extrait 21). La garde côté client évite seulement d'afficher un écran vide ou une série d'erreurs 403. C'est de la défense en profondeur : le frontend guide, l'API décide.

### Accessibilité

Les formulaires utilisent des libellés associés aux champs (`components/ui/forms.tsx`), les tableaux ont des en-têtes de colonnes, les boutons d'action portent un texte et pas seulement une icône, et la navigation latérale est utilisable au clavier. Les graphiques Recharts sont accompagnés de leurs valeurs en cartes (`KpiCard`), pour ne pas dépendre de la couleur seule. Un audit RGAA complet n'a pas été mené ; les points ci-dessus sont ceux vérifiés sur les écrans principaux.

## 2. Composants métier

### Le moteur de recommandations à règles

Le moteur (`backend/app/services/recommendations.py`, classe `RecommendationEngine`) produit une recommandation sans appel externe, à partir du profil, des dernières mesures et des catalogues. Il sert de socle : la route `/api/ai/recommandations` l'exécute d'abord, puis demande au LLM d'enrichir le résultat.

**Extrait 9a — `backend/app/services/recommendations.py`, construction du contexte**

```python
def build(self, db: Session, user: Utilisateur, request: RecommendationRequest) -> RecommendationResponse:
    request = self._request_with_user_defaults(user, request)
    latest_bio = self._latest_biometrie(db, user.utilisateur_id)
    latest_sleep = self._latest_sommeil(db, user.utilisateur_id)
    active_objective = self._active_objective(db, user.utilisateur_id)

    height = user.taille_cm or (latest_bio.taille_cm if latest_bio else None)
    weight = latest_bio.poids_kg if latest_bio else None
    imc = latest_bio.imc if latest_bio else None
    if imc is None and weight and height:
        height_m = float(height) / 100
        imc = round(float(weight) / (height_m * height_m), 2) if height_m else None

    objective_label = request.objectif_principal or (active_objective.type_objectif if active_objective else None) or "sante"
    goal = self._goal_key(objective_label)
    sport_level = self._sport_level(request.niveau_sportif or latest_training_level)

    nutrition, nutrition_messages = self._nutrition_recommendations(db, user.utilisateur_id, request, goal)
    sport, sport_messages = self._sport_recommendations(db, user.utilisateur_id, request, goal, sport_level)
    return RecommendationResponse(
        source="local_rules",
        contexte=context,
        contraintes_prises_en_compte=self._constraints_summary(request),
        nutrition=nutrition,
        sport=sport,
        messages=[m for m in [*nutrition_messages, *sport_messages] if m],
    )
```

**Extrait 9b — `backend/app/services/recommendations.py`, règles d'exclusion**

```python
def food_block_reasons(self, name: str, category: str | None, allergies: list[str], regime: str | None) -> list[str]:
    text = self._normalize(f"{name} {category or ''}")
    reasons: list[str] = []
    for allergy in allergies:
        allergy_key = self._normalize(allergy).replace(" ", "_")
        aliases = ALLERGEN_ALIASES.get(allergy_key) or (self._normalize(allergy),)
        if any(alias and self._normalize(alias) in text for alias in aliases):
            reasons.append(f"allergie ou aliment evite: {allergy}")
    if regime:
        regime_key = self._normalize(regime).replace(" ", "_").replace("-", "_")
        blockers = REGIME_BLOCKERS.get(regime_key, ())
        if any(self._normalize(term) in text for term in blockers):
            reasons.append(f"regime incompatible: {regime}")
    return reasons

def equipment_is_allowed(self, needed: list[str], available: list[str]) -> bool:
    needed_keys = self._canonical_equipment(needed)
    needed_keys.discard("bodyweight")
    if not needed_keys:
        return True
    available_keys = self._canonical_equipment(available)
    if "gym" in available_keys:
        return True
    return needed_keys.issubset(available_keys)

def _exercise_contraindications(self, exercice: Exercice, constraints: list[str]) -> list[str]:
    if not constraints:
        return []
    text = self._normalize(" ".join([exercice.nom, exercice.body_part_principale or "",
                                     exercice.muscle_cible_principal or "", " ".join(self._exercise_muscles(exercice))]))
    constraint_text = self._normalize(" ".join(constraints))
    contraindications: list[str] = []
    if any(t in constraint_text for t in ("genou", "knee")) and any(t in text for t in ("leg", "upper legs", "quads", "glutes", "calves", "jambe", "squat", "lunge")):
        contraindications.append("contrainte genou: exercice bas du corps evite")
    if any(t in constraint_text for t in ("dos", "lombaire", "back")) and any(t in text for t in ("back", "waist", "spine", "deadlift", "row", "dos")):
        contraindications.append("contrainte dos: charge ou flexion du tronc a eviter")
    if any(t in constraint_text for t in ("cardiaque", "coeur", "hypertension", "tension")):
        contraindications.append("contrainte cardio: intensite moderee recommandee")
    return contraindications
```

Pourquoi ce choix : sur des données de santé, une recommandation doit pouvoir être expliquée. Chaque exclusion produit une phrase lisible (« allergie ou aliment evite: arachide », « contrainte genou: exercice bas du corps evite ») qui est renvoyée à l'utilisateur dans `contraintes_prises_en_compte`. Les règles sont déterministes : le même profil donne la même réponse, ce qui rend le jeu d'essai de la section IX reproductible. Les tables `ALLERGEN_ALIASES` et `REGIME_BLOCKERS` gèrent les synonymes (« peanut », « cacahuète », « arachide ») parce que le catalogue d'aliments est en anglais et le profil en français. La méthode `equipment_is_allowed` traite un cas fréquent : un exercice au poids du corps est toujours possible, et un abonnement en salle donne accès à tout.

### L'enrichissement par LLM local

**Extrait 10 — `backend/app/services/ai_enhanced.py`, appel d'Ollama et sélection dans le catalogue**

```python
def _safe_json(s: str):
    try:
        return json.loads(s)
    except Exception:
        return None


class OllamaLLMService:
    async def _call_ollama(self, prompt: str, json_mode: bool = False, temperature: float | None = None) -> str:
        payload: dict = {"model": self.model, "prompt": prompt, "stream": False}
        if json_mode:
            payload["format"] = "json"
        if temperature is not None:
            payload["options"] = {"temperature": temperature}
        async with httpx.AsyncClient(timeout=120.0) as client:
            response = await client.post(f"{self.base_url}/api/generate", json=payload)
            response.raise_for_status()
            return response.json().get("response", "")

    async def select_training_plan(self, profile: dict, program: dict, catalog: list[dict], nb_exercices: int = 5) -> list[dict]:
        if not catalog:
            return []
        catalogue_lignes = "\n".join(
            f"- id={c['id']} | {c['nom']} | groupe: {c['groupe']} | muscle: {c['muscle']} | materiel: {c['materiel']}"
            for c in catalog
        )
        prompt = (
            "Reponds UNIQUEMENT avec un JSON valide, sans texte autour. "
            "Tu es coach sportif certifie qui construit une seance 100% personnalisee.\n\n"
            f"CATALOGUE D'EXERCICES DISPONIBLES:\n{catalogue_lignes}\n\n"
            f"PROFIL DE L'UTILISATEUR: objectif {program.get('objectif')}, niveau {program.get('niveau')}, "
            f"lieu {program.get('lieu')}, materiel {program.get('materiel')}, douleurs {program.get('douleur')}\n"
            f"CONSIGNES: propose exactement {nb_exercices} exercices, privilegie les id du catalogue, "
            "jamais un exercice qui sollicite une zone douloureuse ...\n"
            'Format JSON STRICT: {"exercices":[{"id":12,"nom":"...","series":3,"repetitions":"10-12","justification":"..."}]}'
        )
        raw = await self._call_ollama(prompt, json_mode=True, temperature=0.3)
        parsed = _safe_json(raw)
        # ... extraction de la liste "exercices", validation de chaque élément
```

Pourquoi ce choix : le LLM ne choisit pas librement, il choisit dans un catalogue déjà filtré par les règles (lieu, matériel, douleurs). Chaque exercice retenu porte l'identifiant de la table `exercice`, ce qui permet d'afficher l'animation GIF réelle et d'estimer les calories. Trois précautions rendent la sortie exploitable : le mode `format: json` d'Ollama force une réponse JSON, la température basse (0,3) limite les variations, et `_safe_json` renvoie `None` plutôt qu'une exception si le modèle bavarde quand même. Si la liste est trop courte ou vide, la route complète avec une sélection déterministe (`_fallback_selection`), et l'utilisateur reçoit toujours une séance. Le délai de 120 s est volontairement long : un modèle d'un milliard de paramètres sur un portable sans GPU met parfois plus de trente secondes.

### La route d'analyse de repas et son repli

**Extrait 11 — `backend/app/modules/ai_features.py`, route `POST /api/ai/analyse-repas`**

```python
async def analyse_repas(
    image: UploadFile = File(..., description="Photo du repas (JPEG/PNG)"),
    settings: Settings = Depends(get_settings),
    user: Utilisateur = Depends(current_user),
) -> MealAnalysisResponse:
    image_bytes = await image.read()
    if len(image_bytes) > 10_000_000:
        raise HTTPException(status_code=413, detail="Image trop grande (max 10 Mo)")

    service = GeminiVisionService(settings)
    if not service.is_available():
        document_store.log_ai_call(user.utilisateur_id, "gemini", "gemini-2.5-flash", "unavailable", 0,
                                   {"reason": "GEMINI_API_KEY manquante"})
        raise HTTPException(status_code=503, detail="Gemini Vision non disponible — configurez GEMINI_API_KEY dans .env")

    started = time.perf_counter()
    try:
        foods_raw = await service.analyze(image_bytes)
    except Exception as exc:  # on journalise puis on relaie l'erreur
        document_store.log_ai_call(user.utilisateur_id, "gemini", "gemini-2.5-flash", "error",
                                   int((time.perf_counter() - started) * 1000), {"error": type(exc).__name__})
        raise
    # Liste vide = rien d'exploitable (erreur HTTP, parse, timeout) -> fallback.
    document_store.log_ai_call(user.utilisateur_id, "gemini", "gemini-2.5-flash",
                               "success" if foods_raw else "fallback",
                               int((time.perf_counter() - started) * 1000),
                               {"foods_count": len(foods_raw), "fallback": not foods_raw})

    foods = [DetectedFood(name=f.get("name", "inconnu"), confidence=float(f.get("confidence", 0.0)),
                          quantity_g=f.get("quantity_g"),
                          macros=FoodMacros(**f["macros"]) if f.get("macros") else None)
             for f in foods_raw]
    response = MealAnalysisResponse(foods=foods, total_macros=_sum_macros(foods_raw), source="gemini-2.5-flash")
    document_store.save_meal_analysis(user.utilisateur_id, response.model_dump(mode="json"), source="gemini-2.5-flash")
    return response
```

Pourquoi ce choix : la route est un contrôleur mince. Elle valide l'entrée (taille), délègue au service, journalise chaque issue possible (`unavailable`, `error`, `success`, `fallback`) avec sa durée, et persiste le résultat. Le journal `ai_provider_calls` est ce qui permet ensuite à un administrateur de voir, sur `/api/ai/ai-calls/history`, combien d'appels échouent et en combien de temps. L'absence de clé donne une erreur 503 explicite plutôt qu'un résultat vide : l'exploitant sait quoi corriger.

## 3. Composants d'accès aux données SQL et NoSQL

### CRUD générique et pagination (SQL)

Dix-neuf ressources sont exposées par un seul mécanisme : `create_crud_router` construit un routeur complet (liste, détail, création, mise à jour, suppression) à partir d'une configuration.

**Extrait 12 — `backend/app/modules/resources.py` et `backend/app/core/pagination.py`**

```python
@dataclass
class ResourceConfig:
    path: str
    model: type
    pk: str
    owner_field: str | None = None
    soft_delete_field: str | None = None
    soft_delete_value: Any = None
    sortable_fields: tuple[str, ...] = ()
    searchable_fields: tuple[str, ...] = ()


def _base_query(model: type, owner_field: str | None, user: Utilisateur) -> Select[Any]:
    stmt = select(model)
    if owner_field and user.role == "UTILISATEUR":
        stmt = stmt.where(getattr(model, owner_field) == user.utilisateur_id)
    return stmt
```

```python
def apply_sort(stmt, model, pagination, *, sortable: tuple[str, ...], default_field: str):
    """Apply sort_by/sort_order with whitelist; fall back to default_field desc."""
    field = pagination.sort_by if pagination.sort_by in sortable else default_field
    column = getattr(model, field)
    return stmt.order_by(column.asc() if pagination.sort_order == "asc" else column.desc())


def apply_search(stmt, model, pagination, *, searchable: tuple[str, ...]):
    """Apply LIKE search on whitelisted text fields."""
    if not pagination.search or not searchable:
        return stmt
    pattern = f"%{pagination.search}%"
    clauses = [getattr(model, field).ilike(pattern) for field in searchable if hasattr(model, field)]
    return stmt.where(or_(*clauses)) if clauses else stmt


def paginated_response(data, page, page_size, total, *, filters=None):
    return {
        "data": data,
        "meta": {"page": page, "page_size": page_size, "total": total,
                 "total_pages": ceil(total / page_size) if total else 0},
        "filters": filters or {},
    }
```

Pourquoi ce choix : le filtre par propriétaire est appliqué dans la requête SQL, pas dans le code de chaque route, donc un utilisateur ne peut pas lire les mesures d'un autre même en forgeant un identifiant. Les colonnes de tri et de recherche sont des listes blanches déclarées dans la configuration : un paramètre `sort_by=mot_de_passe_hash` retombe sur la colonne par défaut au lieu de provoquer une erreur ou une fuite. La recherche utilise `ilike` avec un paramètre lié, donc pas d'injection possible. Toutes les listes sont paginées et renvoient le même enveloppe `{data, meta, filters}`, que le composant `data-table` du frontend consomme sans adaptation.

### Modèles SQLAlchemy

**Extrait 13 — `backend/app/db/models.py`, mixin d'audit et modèle `Utilisateur` (début)**

```python
class TimestampMixin:
    cree_le: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)


class Utilisateur(Base):
    __tablename__ = "utilisateur"
    __table_args__ = (
        UniqueConstraint("email", name="uq_utilisateur_email"),
        UniqueConstraint("nom_utilisateur", name="uq_utilisateur_nom_utilisateur"),
        UniqueConstraint("gym_external_id", name="uq_utilisateur_gym_external_id"),
        UniqueConstraint("sleep_external_id", name="uq_utilisateur_sleep_external_id"),
    )

    utilisateur_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    organisation_id: Mapped[int | None] = mapped_column(ForeignKey("organisation.organisation_id"), nullable=True)
    gym_external_id: Mapped[str | None] = mapped_column(String(120))
    sleep_external_id: Mapped[str | None] = mapped_column(String(120))
    nom_utilisateur: Mapped[str] = mapped_column(String(120), nullable=False)
    prenom: Mapped[str | None] = mapped_column(String(120))
    # ... 26 autres colonnes : profil déclaratif, rôle, statut, mot_de_passe_hash
```

Pourquoi ce choix : le style déclaratif de SQLAlchemy 2.0 (`Mapped[...]`) donne des types vérifiables par l'éditeur et par mypy. Les contraintes d'unicité sont nommées, ce qui rend les messages d'erreur lisibles et les migrations prévisibles. Les identifiants externes des deux jeux de données sources (`gym_external_id`, `sleep_external_id`) sont ce qui permet à l'ETL de reconnaître un utilisateur déjà importé et de mettre à jour au lieu de dupliquer.

### Client MongoDB tolérant aux pannes (NoSQL)

**Extrait 14 — `backend/app/db/mongo.py`**

```python
_client: "MongoClient | None" = None
_database = None
_state = "unknown"  # unknown | ready | unavailable
_last_failure = 0.0
_RETRY_COOLDOWN_SECONDS = 20.0


def _connect():
    global _client, _database, _state, _last_failure
    settings = get_settings()
    try:
        client = MongoClient(settings.mongo_url,
                             serverSelectionTimeoutMS=settings.mongo_timeout_ms,
                             connectTimeoutMS=settings.mongo_timeout_ms,
                             uuidRepresentation="standard")
        client.admin.command("ping")
    except PyMongoError as exc:  # on degrade proprement
        _state = "unavailable"
        _last_failure = time.monotonic()
        logger.warning("MongoDB indisponible (%s): persistance NoSQL en mode degrade.", exc)
        return None
    _client, _database, _state = client, client[settings.mongo_db_name], "ready"
    return _database


def get_mongo_db():
    """Retourne la base Mongo, ou ``None`` si indisponible (jamais d'exception)."""
    settings = get_settings()
    if not settings.mongo_enabled:
        return None
    if _database is not None and _state == "ready":
        return _database
    if _state == "unavailable" and (time.monotonic() - _last_failure) < _RETRY_COOLDOWN_SECONDS:
        return None
    return _connect()


def mongo_status() -> str:
    """Statut lisible pour le healthcheck: ok | unavailable | disabled."""
    if not get_settings().mongo_enabled:
        return "disabled"
    return "ok" if get_mongo_db() is not None else "unavailable"
```

Pourquoi ce choix : le délai de sélection du serveur est de 800 ms (`mongo_timeout_ms`), pas les 30 s par défaut de PyMongo ; une base absente ne fige donc pas les requêtes. Après un échec, le client n'insiste pas pendant 20 secondes (`_RETRY_COOLDOWN_SECONDS`), ce qui évite de ralentir chaque appel IA quand Mongo est réellement arrêté, puis retente tout seul. `get_mongo_db` ne lève jamais : c'est le contrat sur lequel s'appuie tout le reste.

**Extrait 15 — `backend/app/services/document_store.py`, collection indexée et écriture**

```python
def _collection(name: str):
    db = mongo.get_mongo_db()
    if db is None:
        return None
    collection = db[name]
    if name not in _indexed:
        try:
            collection.create_index([("utilisateur_id", 1), ("created_at", DESCENDING)])
            _indexed.add(name)
        except PyMongoError as exc:
            logger.warning("Index Mongo non cree sur %s: %s", name, exc)
    return collection


def _save(name: str, utilisateur_id: int, source: str, payload: dict[str, Any]) -> str | None:
    collection = _collection(name)
    if collection is None:
        return None
    document = {"utilisateur_id": utilisateur_id, "source": source,
                "created_at": datetime.now(timezone.utc), "payload": payload}
    try:
        result = collection.insert_one(document)
        return str(result.inserted_id)
    except PyMongoError as exc:
        logger.warning("Ecriture Mongo echouee sur %s: %s", name, exc)
        mongo.invalidate()
        return None
```

*Figure 29 — Document réel de la collection `recommendations` vu dans MongoDB Compass (capture à produire).*

Pourquoi ce choix : tous les documents ont la même enveloppe (`utilisateur_id`, `source`, `created_at`, `payload`), seul `payload` varie. L'index composé correspond exactement à la seule requête faite sur ces collections : les N derniers documents d'un utilisateur, du plus récent au plus ancien. En cas d'erreur d'écriture, `mongo.invalidate()` force une reconnexion au prochain appel plutôt que de garder un client cassé. Le scénario « `docker compose stop mongo` pendant une démonstration » a été joué devant le jury : l'analyse de repas continue de répondre, `/health` indique `documentaire: unavailable`, et tout revient à la normale au redémarrage sans intervention.

## 4. Autres composants

### Contrat d'erreur uniforme

**Extrait 17 — `backend/app/core/errors.py`**

```python
class ApiError(Exception):
    def __init__(self, status_code: int, code: str, message: str, details: Any = None) -> None:
        self.status_code = status_code
        self.code = code
        self.message = message
        self.details = details


def error_payload(code: str, message: str, details: Any = None) -> dict[str, Any]:
    return {"error": {"code": code, "message": message, "details": details}}


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(ApiError)
    async def api_error_handler(_: Request, exc: ApiError) -> JSONResponse:
        return JSONResponse(status_code=exc.status_code,
                            content=error_payload(exc.code, exc.message, exc.details))

    @app.exception_handler(RequestValidationError)
    async def validation_error_handler(_: Request, exc: RequestValidationError) -> JSONResponse:
        errs = exc.errors()
        message = "La requete est invalide."
        if errs:
            first = errs[0]
            loc = [str(p) for p in first.get("loc", []) if p not in ("body", "query", "path")]
            message = f"Champ '{'.'.join(loc) if loc else '?'}' : {first.get('msg', 'invalide')}."
        return JSONResponse(status_code=422, content=error_payload("validation_error", message, errs))

    @app.exception_handler(IntegrityError)
    async def integrity_error_handler(_: Request, exc: IntegrityError) -> JSONResponse:
        return JSONResponse(status_code=409,
                            content=error_payload("conflict", "La contrainte de donnees est violee.", str(exc.orig)))
```

Pourquoi ce choix : toutes les erreurs, qu'elles viennent du code métier (`ApiError`), de la validation Pydantic ou d'une contrainte de base, ont la même forme `{"error": {"code", "message", "details"}}`. Le client (`ApiClientError` dans `api.ts`) n'a qu'un seul format à lire, et le message de validation nomme le champ fautif en français au lieu de renvoyer la structure brute de Pydantic.

### Journalisation corrélée

**Extrait 18 — `backend/app/core/middleware.py`, intégral**

```python
class RequestLogMiddleware(BaseHTTPMiddleware):
    """Attache un request_id et émet une ligne de log par requête HTTP."""

    async def dispatch(self, request: Request, call_next) -> Response:
        request_id = request.headers.get("x-request-id") or uuid.uuid4().hex[:12]
        request.state.request_id = request_id
        log = bind_context(request_id=request_id)
        start = time.perf_counter()
        try:
            response = await call_next(request)
        except Exception:
            duration_ms = (time.perf_counter() - start) * 1000
            log.exception("request_failed method={} path={} duration_ms={:.1f}",
                          request.method, request.url.path, duration_ms)
            raise
        duration_ms = (time.perf_counter() - start) * 1000
        response.headers["x-request-id"] = request_id
        log.info("{} {} -> {} ({:.1f} ms)", request.method, request.url.path, response.status_code, duration_ms)
        return response
```

Pourquoi ce choix : un identifiant de requête est accepté depuis le client ou généré, propagé dans le contexte de journalisation et renvoyé dans la réponse. Quand un utilisateur signale un problème, l'identifiant affiché permet de retrouver la ligne de journal correspondante. La durée est mesurée avec `perf_counter`, y compris en cas d'exception.

### Traçabilité du pipeline ETL

*Figure 30 — Pipeline ETL en cinq étapes, des fichiers sources aux tables métier (archify, `dossier/figures/archify/fig30_pipeline_etl.png`).*

**Extrait 19 — `healthai_etl/etl_common.py`, exécution tracée et règles de qualité déclaratives**

```python
def create_execution(conn, source_id: int) -> int:
    result = conn.execute(text("""
        INSERT INTO execution_etl (
          source_id, statut, demarre_le, lignes_lues, lignes_valides,
          lignes_invalides, nb_doublons_supprimes, nb_valeurs_corrigees,
          nb_rejets, taux_qualite, message
        ) VALUES (:source_id, 'EN_COURS', NOW(), 0, 0, 0, 0, 0, 0, NULL, NULL)
    """), {"source_id": source_id})
    return int(result.lastrowid)


def seed_quality_rules(conn) -> dict[str, int]:
    rules = [
        ("food", "Food_Item", "FOOD_REQUIRED_ITEM", "NULLABILITE", "ERREUR", "Nom aliment obligatoire"),
        ("food", "Calories (kcal)", "FOOD_CAL_RANGE", "BORNE", "AVERT", "Calories entre 0 et 3000"),
        ("gym", "Weight (kg)", "GYM_WEIGHT_RANGE", "BORNE", "ERREUR", "Poids plausible entre 20 et 350 kg"),
        ("gym", "BPM", "GYM_BPM_ORDER", "COHERENCE", "ERREUR", "bpm_max >= bpm_moyen >= bpm_repos"),
        ("gym", "BMI", "GYM_IMC_COH", "COHERENCE", "AVERT", "IMC coherent avec poids et taille"),
        ("sleep", "Blood Pressure", "SLEEP_BP_FORMAT", "FORMAT", "ERREUR", "Format SYS/DIA valide"),
        ("sleep", "Blood Pressure", "SLEEP_BP_ORDER", "COHERENCE", "ERREUR", "SYS > DIA"),
        ("sleep", "Sleep Duration", "SLEEP_HOURS_RANGE", "BORNE", "ERREUR", "Sommeil entre 0 et 24h"),
        ("exercise", "exerciseId", "EX_REQUIRED_ID", "NULLABILITE", "ERREUR", "ID exercice obligatoire"),
        # ... 15 règles au total, de 5 types : NULLABILITE, BORNE, FORMAT, COHERENCE, REFERENTIEL
    ]
    for entite, champ, code, type_regle, severite, description in rules:
        conn.execute(text("""
            INSERT INTO regle_qualite (entite, nom_champ, code_regle, type_regle, severite, description, actif)
            VALUES (:entite, :champ, :code, :type_regle, :severite, :description, 1)
            ON DUPLICATE KEY UPDATE nom_champ = VALUES(nom_champ), type_regle = VALUES(type_regle), ...
        """), {...})
```

Pourquoi ce choix : chaque exécution commence par une ligne `EN_COURS` dans `execution_etl` et se termine par ses compteurs (`finish_execution`), si bien qu'un import interrompu reste visible comme tel dans l'espace administrateur. Les règles de qualité sont des données, pas du code : un administrateur peut désactiver une règle depuis `/admin/regles-qualite` sans redéploiement, et `ON DUPLICATE KEY UPDATE` rend l'initialisation rejouable. Chaque décision (acceptée, avertissement, rejetée) est écrite dans `controle_qualite_donnee` avec la valeur observée et, le cas échéant, la valeur corrigée.

## 5. Éléments de sécurité

### Hachage des mots de passe

**Extrait 20 — `backend/app/core/security.py`, lignes 30-47**

```python
def hash_password_pbkdf2_sha256(password: str, salt: str | None = None, iterations: int = 210000) -> str:
    salt = salt or secrets.token_urlsafe(12)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), iterations)
    digest_b64 = base64.b64encode(digest).decode("ascii").strip()
    return f"pbkdf2_sha256${iterations}${salt}${digest_b64}"


def verify_password(password: str, encoded: str | None) -> bool:
    if not encoded:
        return False
    try:
        algorithm, iterations_raw, salt, expected = encoded.split("$", 3)
        if algorithm != "pbkdf2_sha256":
            return False
        candidate = hash_password_pbkdf2_sha256(password, salt=salt, iterations=int(iterations_raw))
        return hmac.compare_digest(candidate, encoded)
    except (ValueError, TypeError):
        return False
```

Pourquoi ce choix : un sel aléatoire par mot de passe (`secrets.token_urlsafe`), un nombre d'itérations stocké avec le condensé, et une comparaison en temps constant. Le format `algorithme$itérations$sel$condensé` est celui de Django ; il permet d'augmenter les itérations pour les nouveaux comptes sans invalider les anciens, puisque `verify_password` relit le nombre d'itérations dans la chaîne. C'est précisément ce qui rend possible le passage à 600 000 itérations décrit en section X. Le même hachage est utilisé par l'ETL (`hash_password_demo`) pour les comptes générés, afin qu'un seul format existe en base.

### Authentification et rôles

**Extrait 21 — `backend/app/core/security.py`, lignes 104-136**

```python
def current_user(authorization: str | None = Header(default=None), db: Session = Depends(get_db)) -> Utilisateur:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise ApiError(401, "unauthorized", "Authentification requise.")
    payload = decode_token(authorization.split(" ", 1)[1], "access")
    user = db.get(Utilisateur, int(payload["sub"]))
    if not user or user.statut != "ACTIF":
        raise ApiError(401, "unauthorized", "Utilisateur introuvable ou inactif.")
    return user


def require_roles(*roles: str):
    def dependency(user: Utilisateur = Depends(current_user)) -> Utilisateur:
        if user.role not in roles:
            raise ApiError(403, "forbidden", "Droits insuffisants.")
        return user
    return dependency
```

*Figure 31 — Réponse 403 de `GET /api/admin/utilisateurs` appelée avec le compte utilisateur (capture Playwright de la réponse HTTP, `dossier/figures/captures/fig31_admin_403.png`).*

Pourquoi ce choix : `current_user` vérifie le jeton *et* l'état du compte en base à chaque requête ; désactiver un utilisateur (`statut` autre qu'`ACTIF`) prend effet immédiatement, sans attendre l'expiration de son jeton. `require_roles` se compose par-dessus : les deux codes sont distincts (401 pour « qui êtes-vous ? », 403 pour « vous n'avez pas le droit »), ce que le frontend utilise pour rediriger vers la connexion dans un cas et vers le tableau de bord dans l'autre.

### Session : jetons courts et cookie de rafraîchissement

**Extrait 22 — `backend/app/modules/auth.py`, cookie de rafraîchissement et limitation de débit**

```python
def _set_refresh_cookie(response: Response, user: Utilisateur) -> None:
    settings = get_settings()
    refresh_token = create_token(str(user.utilisateur_id), "refresh",
                                 timedelta(days=settings.refresh_token_days), {"role": user.role})
    response.set_cookie(
        "refresh_token",
        refresh_token,
        httponly=True,
        secure=settings.environment == "production",
        samesite="strict",
        max_age=settings.refresh_token_days * 24 * 60 * 60,
    )


@router.post("/login")
@limiter.limit("10/minute")
def login(...):
    ...


@router.post("/forgot-password")
@limiter.limit("5/minute")
def forgot_password(...):
    ...
```

Pourquoi ce choix : le jeton d'accès (30 min) vit en mémoire côté client et n'est jamais écrit dans `localStorage`, donc un script injecté ne peut pas le lire. Le jeton de rafraîchissement (7 jours) est dans un cookie `HttpOnly` (inaccessible à JavaScript) et `SameSite=Strict` (jamais envoyé depuis un autre site, ce qui neutralise la CSRF sur `/refresh`). L'attribut `secure` n'est activé qu'en production pour permettre le développement en HTTP local. La limitation de débit sur la connexion et la réinitialisation de mot de passe freine la force brute et l'énumération de comptes.

### Rafraîchissement sérialisé côté client

**Extrait 23 — `frontend/src/lib/api.ts`**

```ts
let refreshPromise: Promise<string | null> | null = null;

async function refreshAccessToken() {
  if (!refreshPromise) {
    refreshPromise = rawRequest<{ access_token: string }>("/api/auth/refresh", { method: "POST", auth: false, retry: false })
      .then((data) => {
        authHandlers.setToken(data.access_token);
        return data.access_token;
      })
      .catch(() => {
        authHandlers.setToken(null);
        authHandlers.onUnauthorized();
        return null;
      })
      .finally(() => {
        refreshPromise = null;
      });
  }
  return refreshPromise;
}

// dans rawRequest :
if (response.status === 401 && options.auth !== false && options.retry !== false) {
  const refreshed = await refreshAccessToken();
  if (refreshed) {
    return rawRequest<T>(path, { ...options, retry: false });
  }
  throw new ApiClientError(401, { code: "unauthorized", message: "Session expiree." });
}
```

Pourquoi ce choix : un tableau de bord lance cinq ou six requêtes en parallèle. Si le jeton vient d'expirer, toutes reçoivent 401 en même temps. Sans la promesse partagée, le client enverrait cinq appels à `/refresh` ; avec elle, un seul rafraîchissement a lieu et les cinq requêtes sont rejouées avec le nouveau jeton. L'option `retry: false` sur la requête rejouée empêche une boucle si le second appel échoue encore.

---

# IX. Tests

## 1. Stratégie et plan de tests

La stratégie suit la pyramide des tests : beaucoup de tests rapides et isolés sur les règles métier, une couche de tests de contrat sur l'API, et des parcours manuels de bout en bout sur l'interface, tracés dans un tableau. Les tests automatisés sont exécutés à chaque `push` par GitHub Actions ; un échec bloque la fusion.

*Figure 32 — Plan de tests (tableau Word).*

| Niveau | Périmètre | Outil | Nombre | Quand |
|---|---|---|---|---|
| Unitaire | Règles du moteur de recommandations (allergènes, matériel, contraintes de santé, seuil de pertinence, durées de séance) | pytest | 5 | CI |
| Unitaire | Logique du coach posture (comptage des répétitions, maintien statique) | pytest | 2 | CI |
| Unitaire | Fonctions de normalisation de l'ETL (tension, durées, genre, hachage) | pytest | 6 | CI |
| Sécurité | Jetons PyJWT (expiration, type, signature), condensés PBKDF2, refus d'un secret faible en production, accès réseau à `/metrics` | pytest | 18 | CI |
| Contrat API | Authentification, inscription, profil, tableaux de bord, pagination, cloisonnement par rôle et par utilisateur, analyse de repas, recommandations, coach posture, `/health`, OpenAPI | pytest + `TestClient` FastAPI | 29 | CI |
| Bout en bout | Connexion et déconnexion, redirection hors `/admin` et 403 API, exécutions ETL et contrôles qualité paginés | Playwright Test sur la pile Docker | 4 (3 scénarios) | CI, job `e2e` |
| Qualité de code | `ruff check` sur backend et ETL, `eslint` (config Next) sur le frontend | ruff, ESLint | 2 jobs | CI, job `lint` |
| Manuel, bout en bout | Parcours utilisateur, administrateur et super-administrateur ; mode dégradé ; sauvegarde et restauration | navigateur, Docker Compose | 10 cas | avant chaque soutenance |
| Jeu d'essai | Moteur de recommandations sur un profil de référence | script Python sur base SQLite | 1 scénario | ce dossier |

Le total de 64 tests automatisés a été vérifié le 4 septembre 2026 : `pytest -q` renvoie `54 passed` dans `backend/tests` et `6 passed` dans `healthai_etl/tests`, et `npx playwright test` renvoie `4 passed` (le 2 septembre, avant la branche de durcissement, le compte était de 39 : 34 + 5).

## 2. Tests automatisés

### Un test de règle métier

**Extrait 24 — `backend/tests/test_recommendation_rules.py`**

```python
def test_food_allergy_alias_blocks_incompatible_food():
    engine = RecommendationEngine()
    reasons = engine.food_block_reasons("Beurre de cacahuete", "Tartinable", ["arachide"], None)
    assert reasons
    assert "allergie" in reasons[0]


def test_equipment_rule_rejects_missing_material_and_allows_bodyweight():
    engine = RecommendationEngine()
    assert engine.equipment_is_allowed(["body weight"], []) is True
    assert engine.equipment_is_allowed(["dumbbell"], ["tapis"]) is False
    assert engine.equipment_is_allowed(["dumbbell"], ["halteres"]) is True


def test_health_constraint_marks_knee_sensitive_exercise_as_severe():
    engine = RecommendationEngine()
    exercice = Exercice(exercice_id=1, nom="Squat", body_part_principale="upper legs", muscle_cible_principal="quads")
    contraindications = engine._exercise_contraindications(exercice, ["douleur genou"])
    assert contraindications
    assert engine._has_severe_contraindication(contraindications) is True
```

Pourquoi ce choix : chaque test porte le nom de la règle qu'il vérifie, en une phrase lisible par quelqu'un qui n'a pas ouvert le code. Le premier teste le point le plus sensible du moteur, la correspondance entre un allergène déclaré en français (« arachide ») et un aliment du catalogue nommé autrement (« cacahuète »). Le deuxième fixe le comportement attendu sur trois cas de matériel, dont le cas limite « exercice au poids du corps, aucun matériel ». Le troisième vérifie qu'une contrainte de genou rend un squat non seulement déconseillé mais exclu (`severe`). Ces tests tournent en quelques millisecondes, sans base ni serveur.

### Les tests de contrat de l'API

**Extrait 25 — `backend/tests/test_api_contracts.py`, fixture de base de données**

```python
@pytest.fixture()
def testing_session_factory() -> sessionmaker[Session]:
    engine = create_engine(
        "sqlite+pysqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        future=True,
    )
    Base.metadata.create_all(engine)
    TestingSession = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
    with TestingSession() as session:
        org = Organisation(nom="HealthAI Public", adresse="Paris")
        session.add(org)
        session.flush()
        session.add_all([
            Utilisateur(organisation_id=org.organisation_id, nom_utilisateur="alice", email="alice@example.test",
                        role="UTILISATEUR", statut="ACTIF", mot_de_passe_hash=hash_password_pbkdf2_sha256("secret")),
            Utilisateur(organisation_id=org.organisation_id, nom_utilisateur="admin", email="admin@example.test",
                        role="ADMIN", statut="ACTIF", mot_de_passe_hash=hash_password_pbkdf2_sha256("admin-secret")),
        ])
        session.commit()
    return TestingSession
```

Pourquoi ce choix : les 29 tests de contrat tournent sur une base SQLite en mémoire créée depuis les mêmes modèles SQLAlchemy que MariaDB, avec MongoDB désactivé et les appels IA forcés en mode local. Ils n'ont donc besoin d'aucune infrastructure et s'exécutent en une dizaine de secondes, en local comme en CI. Le compromis est connu : SQLite ne vérifie pas tout ce que MariaDB vérifie (types stricts, certaines contraintes). C'est pourquoi les parcours manuels se font sur la pile Docker complète.

Les tests les plus importants pour ce dossier sont ceux qui vérifient la sécurité : `test_role_guard_blocks_regular_user_from_admin_dashboard` (un utilisateur reçoit 403 sur `/api/admin/...`), `test_me_routes_are_scoped_to_authenticated_user` (un utilisateur ne voit que ses propres enregistrements), `test_recommendations_use_profile_defaults_and_keep_user_isolation`, et `test_register_complete_rejects_duplicate_email_and_username`. Deux autres vérifient la résilience : `test_meal_analysis_returns_structured_fallback_when_ai_is_not_configured` et `test_health_and_openapi`.

*Figure 33 — Exécution de la CI GitHub Actions : six jobs verts, `backend-tests`, `etl-tests`, `frontend-build`, `lint`, `e2e` (capture `dossier/figures/captures/fig33_github_actions_checks.png`), et sortie de `pytest -q`.*

```
$ cd backend && python -m pytest -q tests
34 passed, 36 warnings in 11.20s
$ cd healthai_etl && python -m pytest -q tests
5 passed in 0.13s
```

## 3. Tests manuels de bout en bout

Les parcours suivants ont été rejoués sur la pile Docker complète avant chaque soutenance, avec les comptes de démonstration.

| # | Parcours | Résultat attendu | Résultat |
|---|---|---|---|
| M1 | Inscription puis onboarding d'un nouvel utilisateur | Compte créé, profil déclaratif enregistré, redirection vers le tableau de bord | Conforme (rejoué le 2026-09-04 après la montée de Next : `register-complete` 201, arrivée sur `/me/dashboard`) |
| M2 | Connexion, attente de l'expiration du jeton d'accès, navigation | Rafraîchissement transparent, aucune déconnexion | Conforme (rejoué le 2026-09-04 : jeton expiré → 401, `POST /api/auth/refresh` par cookie → 200, navigation après rechargement sans déconnexion) |
| M3 | Utilisateur tape `/admin/dashboard` dans l'URL | Redirection vers `/me/dashboard` ; l'API répond 403 si appelée directement | Conforme (rejoué le 2026-09-04, automatisé dans `frontend/e2e/rbac.spec.ts`) |
| M4 | Lancement de `make etl` puis consultation de `/admin/etl/executions` | Cinq exécutions en succès, compteurs et taux de qualité renseignés, lots créés | Conforme (taux 97,6 % sur la source gym, 23 lignes invalides) |
| M5 | Consultation d'un lot dans `/admin/etl/compare` | Ligne brute, ligne normalisée et décision qualité affichées côte à côte | Conforme |
| M6 | Analyse de repas avec clé Gemini absente | Message explicite « service non configuré », aucune erreur 500 | Conforme |
| M7 | Recommandations avec Ollama arrêté | Réponse `source: unavailable`, l'interface propose de réessayer | Conforme |
| M8 | `docker compose stop mongo` puis analyse de repas et `/health` | Analyse renvoyée, `documentaire: unavailable`, retour à `ok` après `start` | Conforme (démontré en soutenance) |
| M9 | `make backup` puis `make restore` sur un dossier horodaté | Bases MariaDB et MongoDB restaurées, comptes de démonstration présents | Conforme |
| M10 | Tableau de bord Grafana après une série de requêtes | Débit, latence et erreurs 5xx visibles ; panneau 5xx à 0 et non « No data » | Conforme après correctif (section X) |

## 4. Jeu d'essai du moteur de recommandations

La fonctionnalité retenue est le moteur de recommandations à règles. Elle traverse toutes les couches, elle porte les règles de sécurité les plus importantes pour des données de santé, et elle est déterministe : le même profil donne la même sortie, ce qui rend le jeu d'essai vérifiable par le jury. L'analyse de repas par vision, elle, dépend d'un modèle distant dont la réponse varie.

Le scénario a été exécuté le 2 septembre 2026 avec le script `dossier/jeu_essai/jeu_essai_recommandations.py`, qui charge les modèles SQLAlchemy dans une base SQLite, insère les données d'entrée ci-dessous et appelle `RecommendationEngine().build()`. La sortie complète est dans `dossier/jeu_essai/sortie.json`.

### Données en entrée

*Figure 34 — Données en entrée du jeu d'essai (tableau Word).*

Profil de l'utilisatrice (table `utilisateur`, `mesure_biometrique`, `objectif_utilisateur`) :

| Champ | Valeur |
|---|---|
| Prénom, genre, date de naissance | Léa, Femme, 14/03/1997 (29 ans) |
| Taille, dernier poids | 168 cm, 82,0 kg (mesure du 30/08/2026) |
| Objectif actif | `PERTE_POIDS` |
| Allergies déclarées | arachide |
| Équipement disponible | haltères, tapis |
| Contrainte de santé | douleur genou |
| Niveau sportif, fréquence, durée souhaitées | débutant, 3 séances par semaine, 45 min |

Catalogue d'aliments (7 lignes) : Peanut butter (588 kcal), Chicken breast grilled (165), Lentils cooked (116), Salmon baked (208), Greek yogurt plain (59), Croissant (406), Peanut cookies (475).

Catalogue d'exercices (9 lignes) :

| id | Nom | Partie du corps | Matériel |
|---|---|---|---|
| 1 | barbell squat | upper legs | barbell |
| 2 | dumbbell lunge | upper legs | dumbbell |
| 3 | dumbbell bench press | chest | dumbbell |
| 4 | pull-up | back | body weight |
| 5 | push-up | chest | body weight |
| 6 | dumbbell shoulder press | shoulders | dumbbell |
| 7 | plank | waist | body weight |
| 8 | cable row | back | cable |
| 9 | dumbbell bicep curl | upper arms | dumbbell |

Requête : `objectif_principal="perte_poids"`, `allergies=["arachide"]`, `equipement_disponible=["halteres","tapis"]`, `contraintes_sante=["douleur genou"]`, `niveau_sportif="debutant"`, `frequence_seances_hebdo=3`, `duree_seance_min=45`, cinq recommandations maximum par volet.

### Données attendues

*Figure 35 — Données attendues (tableau Word).*

| Élément | Attendu | Règle |
|---|---|---|
| IMC calculé | 82 / 1,68² = 29,05 | calcul dans `build()` quand la mesure n'a pas d'IMC |
| Aliments exclus | Peanut butter, Peanut cookies | allergène « arachide » via `ALLERGEN_ALIASES` |
| Aliments proposés | les 5 restants, protéines en tête (poulet, saumon) pour l'objectif perte de poids | `_nutrition_score` |
| Exercices exclus pour matériel | barbell squat, cable row | `equipment_is_allowed` (barre et poulie absents) |
| Exercice exclu pour la santé | dumbbell lunge (bas du corps, contrainte genou) | `_exercise_contraindications` puis `_has_severe_contraindication` |
| Exercices proposés | 5 parmi bench press, pull-up, push-up, shoulder press, plank, bicep curl | équipement haltères ou poids du corps |
| Intensité, séries | douce, 2 séries, répétitions contrôlées | niveau débutant |
| Messages | 2 aliments exclus, 2 exercices exclus pour matériel, 1 pour santé | compteurs de `build()` |

### Données obtenues

*Figure 36 — Données obtenues (extrait de `sortie.json`).*

Contexte renvoyé : `age: 29`, `imc: 29.05`, `objectif_principal: "perte_poids"`, `niveau_sportif: "debutant"`, `donnees_utilisees: ["profil utilisateur", "catalogue aliments", "catalogue exercices", "derniere biometrie", "objectif actif"]`.

Contraintes prises en compte : `allergies: arachide`, `equipement: halteres, tapis`, `frequence souhaitee: 3/semaine`, `duree seance souhaitee: 45 min`, `contraintes sante: douleur genou`.

Nutrition (dans l'ordre renvoyé) :

| Aliment | Score de pertinence | Justification renvoyée |
|---|---|---|
| Chicken breast grilled | 87 | bon apport protéique, densité calorique compatible avec une perte de poids |
| Salmon baked | 87 | idem |
| Lentils cooked | 73 | densité calorique compatible |
| Greek yogurt plain | 71 | densité calorique compatible |
| Croissant | 57 | « Selectionne depuis le catalogue aliments pour l'objectif perte poids. » |

Sport (séance « Seance perte poids », intensité douce, 44 min) :

| id | Exercice | Matériel | Score pertinence / sécurité | Séries | Durée |
|---|---|---|---|---|---|
| 3 | dumbbell bench press | dumbbell | 61 / 100 | 2 × 8-10 | 11 min |
| 4 | pull-up | body weight | 61 / 100 | 2 × 8-10 | 11 min |
| 5 | push-up | body weight | 61 / 100 | 2 × 8-10 | 11 min |
| 6 | dumbbell shoulder press | dumbbell | 61 / 100 | 2 × 8-10 | 11 min |
| 7 | plank | body weight | 61 / 100 | 2 × 8-10 | 11 min |

Messages : « 2 aliment(s) exclus pour allergie ou regime incompatible. », « 2 exercice(s) exclus car le materiel requis n'etait pas disponible. », « 1 exercice(s) exclus par securite selon les contraintes sante. »

### Analyse des écarts

Les exclusions se comportent exactement comme attendu : les deux produits à l'arachide, le squat à la barre, le rowing à la poulie et la fente (genou) sont écartés, et chaque exclusion est comptée dans les messages. L'IMC et l'âge sont correctement dérivés des données en base. Trois écarts apparaissent néanmoins, et ils sont plus instructifs que les conformités.

**Écart 1 — un croissant recommandé pour une perte de poids.** Le moteur remplit la liste jusqu'à `max_nutrition` (5) avec tout ce qui n'est pas exclu, sans seuil de score. Avec un catalogue de 7 aliments dont 2 exclus, le cinquième candidat est le croissant, score 57, avec une justification vide de contenu. Sur le catalogue réel (593 aliments), le cas ne se présente pas parce que les scores élevés sont nombreux, mais la règle est fausse dans l'absolu. Correction retenue : ne renvoyer que les aliments dont le score de pertinence atteint 65, et compléter par un message « catalogue insuffisant » plutôt que par un aliment médiocre. Ce correctif est référencé en section X.

**Écart 2 — les durées ne s'additionnent pas.** La séance annonce 44 min pour 45 demandées, et chaque exercice affiche 11 min, soit 55 min pour cinq exercices. La durée par exercice est calculée en divisant la durée demandée par un nombre d'exercices fixé avant les exclusions, et la séance recalcule sa durée autrement. Correction : calculer la durée unitaire après la sélection finale et faire de la somme des exercices la durée de la séance.

**Écart 3 — la traction (`pull-up`) passe comme exercice au poids du corps.** Le catalogue ExerciseDB classe la traction en « body weight » alors qu'elle exige une barre. Le moteur applique correctement la règle ; c'est la donnée qui est incomplète. La correction ne relève pas du moteur mais de l'ETL : une règle de qualité `EX_EQUIP_REF` existe déjà pour vérifier que l'équipement est connu, elle ne détecte pas ce cas puisque « body weight » est une valeur valide. Une table de correction manuelle (exercice → équipement réel) est la réponse proportionnée ; elle est notée en perspective.

Ce jeu d'essai est repris dans le support de soutenance, avec ses trois tableaux et l'analyse ci-dessus.

---

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

Depuis le 4 septembre, quatre jobs s'ajoutent : `etl-tests` (pytest sur `healthai_etl`), `lint` (`ruff check` et `eslint`), et `e2e`, qui démarre la pile avec `docker compose up -d --build`, attend `/health`, charge l'ETL, exécute les trois scénarios Playwright et publie le rapport HTML en artefact.

Pourquoi ce choix : les jobs indépendants tournent en parallèle et durent moins de deux minutes grâce au cache des dépendances ; seul `e2e` attend les tests backend et le build. Les tests n'ont besoin d'aucun service externe (SQLite, Mongo désactivé, clé JWT de test), donc le pipeline ne dépend d'aucun secret. Le déclenchement manuel (`workflow_dispatch`) permet de relancer une exécution sans commit. Le pipeline ne couvre pas la qualité du code (lint) ni les tests du pipeline ETL ; les deux sont des ajouts simples, notés en perspective.

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
| `npm audit` du 3 septembre | 4 vulnérabilités hautes (`next`, `postcss`, `nanoid`, `sharp`) | `npm audit fix` puis `next` 16.3.4 ; `npm audit` à 0 vulnérabilité le 4 septembre | `npm run build`, `npm run lint`, parcours M1 à M3 rejoués, tests E2E |
| Jeu d'essai, écart 2 | Durées des exercices et de la séance incohérentes | Calcul de la durée unitaire après sélection, durée de séance = somme | `test_session_duration_matches_exercises` |

Ces correctifs sont de la maintenance évolutive au sens du référentiel : ils ne changent pas les fonctionnalités, ils relèvent le niveau de sécurité et de fiabilité à partir d'informations recueillies par la veille. L'état d'avancement de cette branche sera à jour au moment de la soutenance.

---

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

---

# XII. Conclusion

## Ce que le projet a livré

HealthAI Coaching est une application complète, organisée en couches, qui va de l'import de fichiers hétérogènes jusqu'à des recommandations personnalisées, avec les outils pour l'exploiter : une base relationnelle de vingt tables documentée du conceptuel au physique, un pipeline d'import qui trace chaque ligne et chaque décision de qualité, une API sécurisée à trois rôles documentée par OpenAPI, trois espaces d'interface, un moteur de recommandations explicable enrichi par un modèle local, une persistance documentaire tolérante aux pannes, une intégration continue, une supervision et des sauvegardes. Trois jurys l'ont validée, bloc après bloc.

## Ce dont je suis satisfait

La séparation en couches a tenu à l'usage. Le remplacement de Hugging Face par Gemini, puis l'ajout d'Ollama, se sont faits dans `services/` sans toucher aux routes ni aux schémas ; c'est la preuve que l'architecture n'était pas un dessin de soutenance.

Le mode dégradé est démontrable en direct. Arrêter MongoDB pendant une démonstration et voir l'application continuer, `/health` le signaler, puis tout revenir au redémarrage, est l'argument le plus convaincant que j'ai présenté à un jury.

Le moteur de recommandations refuse de faire ce qu'il ne doit pas faire, et il le dit. Sur des données de santé, une exclusion expliquée vaut mieux qu'une suggestion brillante et opaque.

Enfin, le schéma de base de données de février a survécu à trois lots sans refonte : les index composés et les politiques d'intégrité prévus au départ sont ceux qu'utilisent encore les tableaux de bord et le moteur.

## Ce qui m'a coûté

La gestion du temps. Sans jalons intermédiaires, chaque lot s'est terminé dans des journées trop denses, et la réécriture NestJS du 26 avril est le prix visible de cette absence de cadrage. Le jeu d'essai de la section IX a révélé trois écarts qu'un plan de tests plus systématique aurait trouvés avant la soutenance.

Les sorties des modèles de langage. Obtenir du JSON valide, stable et pertinent d'un modèle d'un milliard de paramètres a demandé plus d'itérations que n'importe quelle autre partie du projet, et la solution finale (mode JSON, température basse, sélection dans un catalogue filtré, repli déterministe) est autant une contrainte d'architecture qu'une technique de prompt.

La coordination sur plusieurs dépôts. Deux lignées de code ont divergé en juin ; la version de référence n'est pas celle où mes commits sont les plus visibles, et une partie de mon travail (PyJWT, contrôle des secrets) revient dans ce dossier sous forme de maintenance plutôt que de livraison initiale.

## Ce que je ferais différemment

Un seul dépôt et des branches dès le premier jour. Un jalonnement daté par périmètre, même sommaire. Des maquettes avant les écrans, ne serait-ce que pour fixer le vocabulaire de l'interface. Un plan de tests écrit avant le code des règles métier, puisque ce sont elles qui portent le risque. Et le déploiement continu dès le lot 1, avec un serveur modeste : la marche manquante de la compétence C11 aurait été franchie sans effort si elle avait été prise au début plutôt qu'en fin de projet.

## Perspectives

À court terme, la branche `cda/security-hardening` : PyJWT, Argon2id ou 600 000 itérations, échec au démarrage sur secret faible, restriction de `/metrics`, seuil de pertinence nutritionnelle, durées de séance cohérentes. Puis la publication d'une image et un déploiement déclenché manuellement sur un serveur derrière un reverse proxy TLS.

À moyen terme : étendre les tests de bout en bout Playwright (trois scénarios en CI depuis septembre) aux parcours super-administrateur, table de correction du catalogue d'exercices, planification et externalisation des sauvegardes, analyse d'impact RGPD et hébergement HDS pour envisager un usage réel.

## Ce que le projet m'a appris

Qu'un concepteur développeur d'applications n'est pas jugé sur ce qu'il sait écrire mais sur ce qu'il sait expliquer, tester et maintenir. Que dire « nous n'avons pas entraîné de modèle » ou « le déploiement continu n'existe pas » devant un jury, avec les raisons, vaut mieux qu'une slide floue. Et que les données de santé imposent une discipline — minimiser, cloisonner, expliquer, garder en local — qui finit par améliorer toute la conception, pas seulement la sécurité.

---

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

---

# Annexe A — Scripts de base de données et contrôle de cohérence

## A.1 Fichiers livrés

Voir `backend/db/README.md` pour l'ordre d'exécution. Les scripts complets `schema_v1_2026-04-25.sql` et `migration_v2_2026-06.sql` sont reproduits intégralement dans cette annexe lors de la mise en page (Phase 4).

## A.2 Cohérence ORM ↔ base (contrôle du 2 septembre 2026)

Comparaison colonne par colonne entre `backend/app/db/models.py` et l'export de la base du 25 avril 2026.

| Table | Colonnes ORM | Colonnes base v1 | Écart |
|---|---|---|---|
| `organisation` | 5 | 5 | identique |
| `regle_qualite` | 8 | 9 |  ; +base: expression_regle |
| `source_donnees` | 7 | 7 | identique |
| `aliment` | 13 | 13 | identique |
| `execution_etl` | 13 | 13 | identique |
| `exercice` | 17 | 17 | identique |
| `utilisateur` | 31 | 16 | +ORM: photo_profil_path, niveau_activite, niveau_sportif, allergies_json, regime_alimentaire, preferences_alimentaires_json, aliments_evites_json, budget_alimentaire, equipements_json, contraintes_sante_json, preferences_sportives_json, frequence_seances_hebdo, duree_seance_min, onboarding_complete, onboarding_complete_le |
| `coach_posture_session` | 19 | — | table créée par migration_v2 |
| `lot_donnees` | 10 | 10 | identique |
| `objectif_utilisateur` | 10 | 8 | +ORM: poids_cible_kg, statut_objectif |
| `controle_qualite_donnee` | 19 | 19 | identique |
| `enregistrement_brut` | 6 | 6 | identique |
| `mesure_biometrique` | 16 | 16 | identique |
| `mesure_sommeil_sante` | 22 | 22 | identique |
| `plat` | 9 | 9 | identique |
| `progression_photo` | 7 | 7 | identique |
| `seance_entrainement` | 12 | 12 | identique |
| `stg_import` | 10 | 10 | identique |
| `journal_alimentaire` | 14 | 14 | identique |
| `seance_exercice` | 11 | 11 | identique |

Les écarts `+ORM` sont exactement le contenu de `migration_v2_2026-06.sql`. L'écart `+base` (`regle_qualite.expression_regle`) est une colonne inutilisée à supprimer dans une migration ultérieure.

### A.3 — `backend/db/migration_v2_2026-06.sql` (intégral)

```sql
-- ============================================================================
-- HealthAI Coaching — migration v1 → v2 (juin 2026, MSPR Bloc 2 / Blocs 3-4)
-- Applique sur schema_v1_2026-04-25.sql les évolutions portées par backend/app/db/models.py :
--   1. profil déclaratif et onboarding sur `utilisateur` (moteur de recommandations)
--   2. cible et statut sur `objectif_utilisateur`
--   3. nouvelle table `coach_posture_session` (coach posture MediaPipe)
-- Rejouable : chaque instruction ignore l'élément s'il existe déjà (MariaDB >= 10.2).
-- ============================================================================
START TRANSACTION;

-- 1. Profil déclaratif utilisé par le moteur de recommandations + suivi d'onboarding
ALTER TABLE `utilisateur`
  ADD COLUMN IF NOT EXISTS `photo_profil_path`            varchar(500) DEFAULT NULL AFTER `taille_cm`,
  ADD COLUMN IF NOT EXISTS `niveau_activite`              varchar(80)  DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `niveau_sportif`               varchar(80)  DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `allergies_json`               text         DEFAULT NULL COMMENT 'liste JSON, ex. ["arachide"]',
  ADD COLUMN IF NOT EXISTS `regime_alimentaire`           varchar(120) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `preferences_alimentaires_json` text        DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `aliments_evites_json`         text         DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `budget_alimentaire`           varchar(80)  DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `equipements_json`             text         DEFAULT NULL COMMENT 'liste JSON, ex. ["halteres","tapis"]',
  ADD COLUMN IF NOT EXISTS `contraintes_sante_json`       text         DEFAULT NULL COMMENT 'liste JSON, ex. ["douleur genou"]',
  ADD COLUMN IF NOT EXISTS `preferences_sportives_json`   text         DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `frequence_seances_hebdo`      int(10) UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `duree_seance_min`             int(10) UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `onboarding_complete`          tinyint(1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `onboarding_complete_le`       datetime DEFAULT NULL;

-- 2. Objectif : poids cible et statut de suivi
ALTER TABLE `objectif_utilisateur`
  ADD COLUMN IF NOT EXISTS `poids_cible_kg`  decimal(8,2) DEFAULT NULL AFTER `type_objectif`,
  ADD COLUMN IF NOT EXISTS `statut_objectif` varchar(30) NOT NULL DEFAULT 'EN_COURS' COMMENT 'EN_COURS | TERMINE | ANNULE | ARCHIVE' AFTER `actif_unique`;

-- 3. Sessions du coach posture (analyse MediaPipe côté navigateur, résultat validé côté API)
CREATE TABLE IF NOT EXISTS `coach_posture_session` (
  `coach_posture_id`     bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `utilisateur_id`       bigint(20) UNSIGNED NOT NULL,
  `exercice_code`        varchar(80)  NOT NULL,
  `exercice_nom`         varchar(120) NOT NULL,
  `type_exercice`        varchar(20)  NOT NULL COMMENT 'dynamic | static',
  `statut_posture`       varchar(40)  NOT NULL,
  `score_alignement`     int(10) UNSIGNED NOT NULL DEFAULT 0,
  `reps`                 int(10) UNSIGNED NOT NULL DEFAULT 0,
  `reps_in_current_set`  int(10) UNSIGNED NOT NULL DEFAULT 0,
  `sets_count`           int(10) UNSIGNED NOT NULL DEFAULT 0,
  `hold_seconds`         int(10) UNSIGNED NOT NULL DEFAULT 0,
  `best_hold_seconds`    int(10) UNSIGNED NOT NULL DEFAULT 0,
  `validated_holds`      int(10) UNSIGNED NOT NULL DEFAULT 0,
  `detected_errors_json` text DEFAULT NULL,
  `feedback_json`        text DEFAULT NULL,
  `snapshot_path`        varchar(500) DEFAULT NULL,
  `source_page`          varchar(80)  NOT NULL DEFAULT 'coach_posture',
  `valide_le`            datetime NOT NULL,
  `cree_le`              datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`coach_posture_id`),
  KEY `idx_coach_posture_utilisateur_date` (`utilisateur_id`,`valide_le`),
  CONSTRAINT `fk_coach_posture_utilisateur` FOREIGN KEY (`utilisateur_id`)
    REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;
```

### A.4 — `backend/db/schema_v1_2026-04-25.sql` (intégral, 19 tables)

```sql
-- ============================================================================
-- HealthAI Coaching — schéma relationnel v1 (MariaDB 10.x)
-- Source : export phpMyAdmin de la base `healthai_coaching` du 25 avril 2026
--          (livraison MSPR Bloc 1), données retirées, compteurs AUTO_INCREMENT remis à zéro.
-- 19 tables : 12 métier + 7 pilotage ETL. Voir migration_v2_2026-06.sql pour l'état courant.
-- ============================================================================
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `healthai_coaching`
--

-- --------------------------------------------------------

--
-- Structure de la table `aliment`
--

CREATE TABLE `aliment` (
  `aliment_id` bigint(20) UNSIGNED NOT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `nom` varchar(255) NOT NULL,
  `categorie` varchar(120) DEFAULT NULL,
  `calories_kcal` decimal(10,2) DEFAULT NULL,
  `proteines_g` decimal(10,2) DEFAULT NULL,
  `glucides_g` decimal(10,2) DEFAULT NULL,
  `lipides_g` decimal(10,2) DEFAULT NULL,
  `fibres_g` decimal(10,2) DEFAULT NULL,
  `sucres_g` decimal(10,2) DEFAULT NULL,
  `sodium_mg` decimal(10,2) DEFAULT NULL,
  `cholesterol_mg` decimal(10,2) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `controle_qualite_donnee`
--

CREATE TABLE `controle_qualite_donnee` (
  `controle_id` bigint(20) UNSIGNED NOT NULL,
  `execution_id` bigint(20) UNSIGNED NOT NULL,
  `lot_id` bigint(20) UNSIGNED DEFAULT NULL,
  `regle_id` bigint(20) UNSIGNED DEFAULT NULL,
  `entite` varchar(80) NOT NULL,
  `ref_externe` varchar(120) DEFAULT NULL,
  `ref_ligne` varchar(80) DEFAULT NULL,
  `nom_champ` varchar(120) DEFAULT NULL,
  `valeur_observee` varchar(255) DEFAULT NULL,
  `valeur_corrigee` varchar(255) DEFAULT NULL,
  `payload_json` longtext DEFAULT NULL,
  `niveau` enum('INFO','AVERT','ERREUR') NOT NULL DEFAULT 'INFO',
  `type_controle` enum('FORMAT','NULLABILITE','BORNE','COHERENCE','DUPLICATION','REFERENTIEL','BUSINESS','AUTRE') NOT NULL DEFAULT 'AUTRE',
  `decision_finale` enum('ACCEPTEE','ACCEPTEE_AVEC_AVERTISSEMENT','CORRIGEE','REJETEE') NOT NULL DEFAULT 'ACCEPTEE',
  `est_bloquant` tinyint(1) NOT NULL DEFAULT 0,
  `code_controle` varchar(80) NOT NULL,
  `description` varchar(500) NOT NULL,
  `etape_pipeline` enum('RAW','STAGING','VALIDATION','CHARGEMENT') NOT NULL DEFAULT 'VALIDATION',
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `enregistrement_brut`
--

CREATE TABLE `enregistrement_brut` (
  `enregistrement_id` bigint(20) UNSIGNED NOT NULL,
  `lot_id` bigint(20) UNSIGNED NOT NULL,
  `entite` varchar(80) NOT NULL,
  `ref_externe` varchar(120) DEFAULT NULL,
  `payload_json` longtext NOT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `execution_etl`
--

CREATE TABLE `execution_etl` (
  `execution_id` bigint(20) UNSIGNED NOT NULL,
  `source_id` bigint(20) UNSIGNED NOT NULL,
  `statut` enum('EN_COURS','SUCCES','ECHEC','AVERTISSEMENT','ANNULE') NOT NULL DEFAULT 'EN_COURS',
  `demarre_le` datetime NOT NULL DEFAULT current_timestamp(),
  `termine_le` datetime DEFAULT NULL,
  `lignes_lues` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `lignes_valides` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `lignes_invalides` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `nb_doublons_supprimes` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `nb_valeurs_corrigees` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `nb_rejets` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `taux_qualite` decimal(6,2) DEFAULT NULL,
  `message` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `exercice`
--

CREATE TABLE `exercice` (
  `exercice_id` bigint(20) UNSIGNED NOT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `external_id` varchar(80) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `gif_180_path` varchar(500) DEFAULT NULL,
  `gif_360_path` varchar(500) DEFAULT NULL,
  `gif_720_path` varchar(500) DEFAULT NULL,
  `gif_1080_path` varchar(500) DEFAULT NULL,
  `body_part_principale` varchar(120) DEFAULT NULL,
  `muscle_cible_principal` varchar(120) DEFAULT NULL,
  `equipement_principal` varchar(120) DEFAULT NULL,
  `body_parts_json` longtext DEFAULT NULL,
  `target_muscles_json` longtext DEFAULT NULL,
  `secondary_muscles_json` longtext DEFAULT NULL,
  `equipments_json` longtext DEFAULT NULL,
  `instructions_json` longtext DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `journal_alimentaire`
--

CREATE TABLE `journal_alimentaire` (
  `journal_id` bigint(20) UNSIGNED NOT NULL,
  `utilisateur_id` bigint(20) UNSIGNED NOT NULL,
  `plat_id` bigint(20) UNSIGNED DEFAULT NULL,
  `aliment_id` bigint(20) UNSIGNED DEFAULT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `lot_id` bigint(20) UNSIGNED DEFAULT NULL,
  `consomme_le` datetime NOT NULL,
  `type_repas` enum('PetitDejeuner','Dejeuner','Diner','Collation','Autre','Inconnu') NOT NULL DEFAULT 'Inconnu',
  `aliment_nom_libre` varchar(255) DEFAULT NULL,
  `quantite` decimal(10,2) DEFAULT NULL,
  `unite_quantite` varchar(30) DEFAULT NULL,
  `calories_kcal` decimal(10,2) DEFAULT NULL,
  `eau_ml` decimal(10,2) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `lot_donnees`
--

CREATE TABLE `lot_donnees` (
  `lot_id` bigint(20) UNSIGNED NOT NULL,
  `execution_id` bigint(20) UNSIGNED NOT NULL,
  `source_id` bigint(20) UNSIGNED NOT NULL,
  `nom_lot` varchar(200) NOT NULL,
  `statut` enum('TELEVERSE','VALIDE','NETTOYE','REJETE','APPROUVE','PARTIEL') NOT NULL DEFAULT 'TELEVERSE',
  `cree_par_utilisateur_id` bigint(20) UNSIGNED DEFAULT NULL,
  `valide_par_utilisateur_id` bigint(20) UNSIGNED DEFAULT NULL,
  `valide_le` datetime DEFAULT NULL,
  `commentaire_validation` varchar(500) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `mesure_biometrique`
--

CREATE TABLE `mesure_biometrique` (
  `mesure_id` bigint(20) UNSIGNED NOT NULL,
  `utilisateur_id` bigint(20) UNSIGNED NOT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `lot_id` bigint(20) UNSIGNED DEFAULT NULL,
  `mesure_le` datetime NOT NULL,
  `age_source` smallint(5) UNSIGNED DEFAULT NULL,
  `genre_source` varchar(30) DEFAULT NULL,
  `poids_kg` decimal(8,2) DEFAULT NULL,
  `taille_cm` decimal(6,2) DEFAULT NULL,
  `imc` decimal(6,2) DEFAULT NULL,
  `taux_masse_grasse` decimal(6,2) DEFAULT NULL,
  `bpm_repos` smallint(5) UNSIGNED DEFAULT NULL,
  `bpm_moyen` smallint(5) UNSIGNED DEFAULT NULL,
  `bpm_max` smallint(5) UNSIGNED DEFAULT NULL,
  `eau_l` decimal(8,2) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `mesure_sommeil_sante`
--

CREATE TABLE `mesure_sommeil_sante` (
  `mesure_sommeil_id` bigint(20) UNSIGNED NOT NULL,
  `utilisateur_id` bigint(20) UNSIGNED NOT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `lot_id` bigint(20) UNSIGNED DEFAULT NULL,
  `mesure_le` datetime NOT NULL,
  `person_id_source` varchar(60) DEFAULT NULL,
  `genre_source` varchar(30) DEFAULT NULL,
  `age_source` smallint(5) UNSIGNED DEFAULT NULL,
  `profession` varchar(120) DEFAULT NULL,
  `duree_sommeil_h` decimal(5,2) DEFAULT NULL,
  `qualite_sommeil_score` decimal(4,2) DEFAULT NULL,
  `activite_physique_min_jour` decimal(8,2) DEFAULT NULL,
  `stress_score` decimal(4,2) DEFAULT NULL,
  `categorie_imc_source` varchar(60) DEFAULT NULL,
  `tension_arterielle_brut` varchar(40) DEFAULT NULL,
  `tension_systolique` smallint(5) UNSIGNED DEFAULT NULL,
  `tension_diastolique` smallint(5) UNSIGNED DEFAULT NULL,
  `frequence_cardiaque_bpm` smallint(5) UNSIGNED DEFAULT NULL,
  `pas_jour` int(10) UNSIGNED DEFAULT NULL,
  `trouble_sommeil_brut` varchar(60) DEFAULT NULL,
  `trouble_sommeil_normalise` varchar(40) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `objectif_utilisateur`
--

CREATE TABLE `objectif_utilisateur` (
  `objectif_id` bigint(20) UNSIGNED NOT NULL,
  `utilisateur_id` bigint(20) UNSIGNED NOT NULL,
  `type_objectif` enum('PERTE_POIDS','GAIN_MUSCLE','SOMMEIL','EQUILIBRE_VIE','MAINTIEN_FORME','AUTRE') NOT NULL,
  `date_debut` date NOT NULL,
  `date_fin` date DEFAULT NULL,
  `actif_unique` tinyint(1) NOT NULL DEFAULT 1,
  `commentaire` varchar(255) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `organisation`
--

CREATE TABLE `organisation` (
  `organisation_id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(150) NOT NULL,
  `adresse` varchar(255) DEFAULT NULL,
  `image_path` varchar(500) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `plat`
--

CREATE TABLE `plat` (
  `plat_id` bigint(20) UNSIGNED NOT NULL,
  `utilisateur_id` bigint(20) UNSIGNED NOT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `lot_id` bigint(20) UNSIGNED DEFAULT NULL,
  `consomme_le` datetime NOT NULL,
  `type_repas` enum('PetitDejeuner','Dejeuner','Diner','Collation','Autre','Inconnu') NOT NULL DEFAULT 'Inconnu',
  `nom_plat` varchar(255) DEFAULT NULL,
  `calories_totales_kcal` decimal(10,2) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `progression_photo`
--

CREATE TABLE `progression_photo` (
  `photo_id` bigint(20) UNSIGNED NOT NULL,
  `utilisateur_id` bigint(20) UNSIGNED NOT NULL,
  `objectif_id` bigint(20) UNSIGNED DEFAULT NULL,
  `type_photo` enum('BEFORE','AFTER','AUTRE') NOT NULL,
  `image_path` varchar(500) NOT NULL,
  `prise_le` date NOT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `regle_qualite`
--

CREATE TABLE `regle_qualite` (
  `regle_id` bigint(20) UNSIGNED NOT NULL,
  `entite` varchar(80) NOT NULL,
  `nom_champ` varchar(120) DEFAULT NULL,
  `code_regle` varchar(80) NOT NULL,
  `type_regle` enum('NULLABILITE','FORMAT','BORNE','COHERENCE','DUPLICAT','REFERENTIEL','BUSINESS') NOT NULL,
  `severite` enum('INFO','AVERT','ERREUR','CRITIQUE') NOT NULL DEFAULT 'ERREUR',
  `expression_regle` text DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `seance_entrainement`
--

CREATE TABLE `seance_entrainement` (
  `seance_id` bigint(20) UNSIGNED NOT NULL,
  `utilisateur_id` bigint(20) UNSIGNED NOT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `lot_id` bigint(20) UNSIGNED DEFAULT NULL,
  `date_seance` datetime NOT NULL,
  `type_entrainement` varchar(50) NOT NULL,
  `duree_seance_min` int(10) UNSIGNED DEFAULT NULL,
  `calories_brulees_total` decimal(10,2) DEFAULT NULL,
  `frequence_entrainement_j_sem` decimal(10,2) DEFAULT NULL,
  `niveau_experience` varchar(30) DEFAULT NULL,
  `eau_l` decimal(8,2) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `seance_exercice`
--

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
  `commentaire` varchar(255) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `source_donnees`
--

CREATE TABLE `source_donnees` (
  `source_id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(200) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `type_source` varchar(50) DEFAULT NULL,
  `format_source` varchar(30) DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `stg_import`
--

CREATE TABLE `stg_import` (
  `stg_id` bigint(20) UNSIGNED NOT NULL,
  `lot_id` bigint(20) UNSIGNED NOT NULL,
  `entite` varchar(80) NOT NULL,
  `ref_externe` varchar(120) DEFAULT NULL,
  `source_payload_json` longtext DEFAULT NULL,
  `payload_normalise_json` longtext DEFAULT NULL,
  `est_parseable` tinyint(1) NOT NULL DEFAULT 0,
  `statut_validation` enum('EN_ATTENTE','VALIDE','AVERTISSEMENT','REJETE') NOT NULL DEFAULT 'EN_ATTENTE',
  `code_rejet_potentiel` varchar(80) DEFAULT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Structure de la table `utilisateur`
--

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


--
-- Index pour les tables déchargées
--

--
-- Index pour la table `aliment`
--
ALTER TABLE `aliment`
  ADD PRIMARY KEY (`aliment_id`),
  ADD KEY `idx_aliment_source` (`source_id`),
  ADD KEY `idx_aliment_nom` (`nom`),
  ADD KEY `idx_aliment_categorie` (`categorie`);

--
-- Index pour la table `controle_qualite_donnee`
--
ALTER TABLE `controle_qualite_donnee`
  ADD PRIMARY KEY (`controle_id`),
  ADD KEY `idx_cq_execution_niveau` (`execution_id`,`niveau`),
  ADD KEY `idx_cq_lot_entite` (`lot_id`,`entite`),
  ADD KEY `idx_cq_code` (`code_controle`),
  ADD KEY `idx_cq_type` (`type_controle`),
  ADD KEY `idx_cq_decision` (`decision_finale`),
  ADD KEY `idx_cq_entite_ref` (`entite`,`ref_externe`),
  ADD KEY `idx_cq_regle` (`regle_id`);

--
-- Index pour la table `enregistrement_brut`
--
ALTER TABLE `enregistrement_brut`
  ADD PRIMARY KEY (`enregistrement_id`),
  ADD KEY `idx_brut_lot_entite` (`lot_id`,`entite`),
  ADD KEY `idx_brut_ref_externe` (`ref_externe`);

--
-- Index pour la table `execution_etl`
--
ALTER TABLE `execution_etl`
  ADD PRIMARY KEY (`execution_id`),
  ADD KEY `idx_execution_source_date` (`source_id`,`demarre_le`),
  ADD KEY `idx_execution_statut` (`statut`);

--
-- Index pour la table `exercice`
--
ALTER TABLE `exercice`
  ADD PRIMARY KEY (`exercice_id`),
  ADD UNIQUE KEY `uq_exercice_external_id` (`external_id`),
  ADD KEY `idx_exercice_source` (`source_id`),
  ADD KEY `idx_exercice_nom` (`nom`),
  ADD KEY `idx_exercice_body_part` (`body_part_principale`),
  ADD KEY `idx_exercice_muscle` (`muscle_cible_principal`),
  ADD KEY `idx_exercice_equipement` (`equipement_principal`);

--
-- Index pour la table `journal_alimentaire`
--
ALTER TABLE `journal_alimentaire`
  ADD PRIMARY KEY (`journal_id`),
  ADD KEY `idx_journal_utilisateur_date` (`utilisateur_id`,`consomme_le`),
  ADD KEY `idx_journal_aliment` (`aliment_id`),
  ADD KEY `idx_journal_type_repas` (`type_repas`),
  ADD KEY `idx_journal_source` (`source_id`),
  ADD KEY `idx_journal_lot` (`lot_id`),
  ADD KEY `idx_journal_plat` (`plat_id`);

--
-- Index pour la table `lot_donnees`
--
ALTER TABLE `lot_donnees`
  ADD PRIMARY KEY (`lot_id`),
  ADD UNIQUE KEY `uq_lot_source_nom` (`source_id`,`nom_lot`),
  ADD KEY `idx_lot_execution` (`execution_id`),
  ADD KEY `idx_lot_statut` (`statut`),
  ADD KEY `idx_lot_cree_par` (`cree_par_utilisateur_id`),
  ADD KEY `idx_lot_valide_par` (`valide_par_utilisateur_id`);

--
-- Index pour la table `mesure_biometrique`
--
ALTER TABLE `mesure_biometrique`
  ADD PRIMARY KEY (`mesure_id`),
  ADD KEY `idx_mesure_bio_utilisateur_date` (`utilisateur_id`,`mesure_le`),
  ADD KEY `idx_mesure_bio_source` (`source_id`),
  ADD KEY `idx_mesure_bio_lot` (`lot_id`);

--
-- Index pour la table `mesure_sommeil_sante`
--
ALTER TABLE `mesure_sommeil_sante`
  ADD PRIMARY KEY (`mesure_sommeil_id`),
  ADD KEY `idx_mesure_sommeil_utilisateur_date` (`utilisateur_id`,`mesure_le`),
  ADD KEY `idx_mesure_sommeil_source` (`source_id`),
  ADD KEY `idx_mesure_sommeil_lot` (`lot_id`),
  ADD KEY `idx_mesure_sommeil_trouble` (`trouble_sommeil_normalise`);

--
-- Index pour la table `objectif_utilisateur`
--
ALTER TABLE `objectif_utilisateur`
  ADD PRIMARY KEY (`objectif_id`),
  ADD KEY `idx_objectif_utilisateur` (`utilisateur_id`),
  ADD KEY `idx_objectif_utilisateur_actif` (`utilisateur_id`,`actif_unique`),
  ADD KEY `idx_objectif_dates` (`date_debut`,`date_fin`);

--
-- Index pour la table `organisation`
--
ALTER TABLE `organisation`
  ADD PRIMARY KEY (`organisation_id`),
  ADD UNIQUE KEY `uq_organisation_nom` (`nom`);

--
-- Index pour la table `plat`
--
ALTER TABLE `plat`
  ADD PRIMARY KEY (`plat_id`),
  ADD KEY `idx_plat_utilisateur_date` (`utilisateur_id`,`consomme_le`),
  ADD KEY `idx_plat_source` (`source_id`),
  ADD KEY `idx_plat_lot` (`lot_id`);

--
-- Index pour la table `progression_photo`
--
ALTER TABLE `progression_photo`
  ADD PRIMARY KEY (`photo_id`),
  ADD KEY `idx_photo_utilisateur` (`utilisateur_id`),
  ADD KEY `idx_photo_objectif` (`objectif_id`);

--
-- Index pour la table `regle_qualite`
--
ALTER TABLE `regle_qualite`
  ADD PRIMARY KEY (`regle_id`),
  ADD UNIQUE KEY `uq_regle_code` (`code_regle`),
  ADD KEY `idx_regle_entite` (`entite`),
  ADD KEY `idx_regle_actif` (`actif`);

--
-- Index pour la table `seance_entrainement`
--
ALTER TABLE `seance_entrainement`
  ADD PRIMARY KEY (`seance_id`),
  ADD KEY `idx_seance_utilisateur_date` (`utilisateur_id`,`date_seance`),
  ADD KEY `idx_seance_type` (`type_entrainement`),
  ADD KEY `idx_seance_source` (`source_id`),
  ADD KEY `idx_seance_lot` (`lot_id`);

--
-- Index pour la table `seance_exercice`
--
ALTER TABLE `seance_exercice`
  ADD PRIMARY KEY (`seance_exercice_id`),
  ADD UNIQUE KEY `uq_seance_exercice_ordre` (`seance_id`,`ordre_exercice`,`exercice_id`),
  ADD KEY `idx_seance_exercice_seance` (`seance_id`),
  ADD KEY `idx_seance_exercice_exercice` (`exercice_id`);

--
-- Index pour la table `source_donnees`
--
ALTER TABLE `source_donnees`
  ADD PRIMARY KEY (`source_id`),
  ADD UNIQUE KEY `uq_source_nom` (`nom`);

--
-- Index pour la table `stg_import`
--
ALTER TABLE `stg_import`
  ADD PRIMARY KEY (`stg_id`),
  ADD KEY `idx_stg_lot_entite` (`lot_id`,`entite`),
  ADD KEY `idx_stg_statut` (`statut_validation`),
  ADD KEY `idx_stg_parseable` (`est_parseable`);

--
-- Index pour la table `utilisateur`
--
ALTER TABLE `utilisateur`
  ADD PRIMARY KEY (`utilisateur_id`),
  ADD UNIQUE KEY `uq_utilisateur_nom_utilisateur` (`nom_utilisateur`),
  ADD UNIQUE KEY `uq_utilisateur_email` (`email`),
  ADD UNIQUE KEY `uq_utilisateur_gym_external_id` (`gym_external_id`),
  ADD UNIQUE KEY `uq_utilisateur_sleep_external_id` (`sleep_external_id`),
  ADD KEY `idx_utilisateur_organisation` (`organisation_id`),
  ADD KEY `idx_utilisateur_role_statut` (`role`,`statut`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `aliment`
--
ALTER TABLE `aliment`
  MODIFY `aliment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `controle_qualite_donnee`
--
ALTER TABLE `controle_qualite_donnee`
  MODIFY `controle_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `enregistrement_brut`
--
ALTER TABLE `enregistrement_brut`
  MODIFY `enregistrement_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `execution_etl`
--
ALTER TABLE `execution_etl`
  MODIFY `execution_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `exercice`
--
ALTER TABLE `exercice`
  MODIFY `exercice_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `journal_alimentaire`
--
ALTER TABLE `journal_alimentaire`
  MODIFY `journal_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `lot_donnees`
--
ALTER TABLE `lot_donnees`
  MODIFY `lot_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `mesure_biometrique`
--
ALTER TABLE `mesure_biometrique`
  MODIFY `mesure_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `mesure_sommeil_sante`
--
ALTER TABLE `mesure_sommeil_sante`
  MODIFY `mesure_sommeil_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `objectif_utilisateur`
--
ALTER TABLE `objectif_utilisateur`
  MODIFY `objectif_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `organisation`
--
ALTER TABLE `organisation`
  MODIFY `organisation_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `plat`
--
ALTER TABLE `plat`
  MODIFY `plat_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `progression_photo`
--
ALTER TABLE `progression_photo`
  MODIFY `photo_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `regle_qualite`
--
ALTER TABLE `regle_qualite`
  MODIFY `regle_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `seance_entrainement`
--
ALTER TABLE `seance_entrainement`
  MODIFY `seance_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `seance_exercice`
--
ALTER TABLE `seance_exercice`
  MODIFY `seance_exercice_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `source_donnees`
--
ALTER TABLE `source_donnees`
  MODIFY `source_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `stg_import`
--
ALTER TABLE `stg_import`
  MODIFY `stg_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- AUTO_INCREMENT pour la table `utilisateur`
--
ALTER TABLE `utilisateur`
  MODIFY `utilisateur_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT ;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `aliment`
--
ALTER TABLE `aliment`
  ADD CONSTRAINT `fk_aliment_source` FOREIGN KEY (`source_id`) REFERENCES `source_donnees` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `controle_qualite_donnee`
--
ALTER TABLE `controle_qualite_donnee`
  ADD CONSTRAINT `fk_cq_execution` FOREIGN KEY (`execution_id`) REFERENCES `execution_etl` (`execution_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cq_lot` FOREIGN KEY (`lot_id`) REFERENCES `lot_donnees` (`lot_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cq_regle` FOREIGN KEY (`regle_id`) REFERENCES `regle_qualite` (`regle_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `enregistrement_brut`
--
ALTER TABLE `enregistrement_brut`
  ADD CONSTRAINT `fk_brut_lot` FOREIGN KEY (`lot_id`) REFERENCES `lot_donnees` (`lot_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `execution_etl`
--
ALTER TABLE `execution_etl`
  ADD CONSTRAINT `fk_execution_source` FOREIGN KEY (`source_id`) REFERENCES `source_donnees` (`source_id`) ON UPDATE CASCADE;

--
-- Contraintes pour la table `exercice`
--
ALTER TABLE `exercice`
  ADD CONSTRAINT `fk_exercice_source` FOREIGN KEY (`source_id`) REFERENCES `source_donnees` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `journal_alimentaire`
--
ALTER TABLE `journal_alimentaire`
  ADD CONSTRAINT `fk_journal_aliment` FOREIGN KEY (`aliment_id`) REFERENCES `aliment` (`aliment_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_journal_lot` FOREIGN KEY (`lot_id`) REFERENCES `lot_donnees` (`lot_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_journal_plat` FOREIGN KEY (`plat_id`) REFERENCES `plat` (`plat_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_journal_source` FOREIGN KEY (`source_id`) REFERENCES `source_donnees` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_journal_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `lot_donnees`
--
ALTER TABLE `lot_donnees`
  ADD CONSTRAINT `fk_lot_cree_par` FOREIGN KEY (`cree_par_utilisateur_id`) REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_lot_execution` FOREIGN KEY (`execution_id`) REFERENCES `execution_etl` (`execution_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_lot_source` FOREIGN KEY (`source_id`) REFERENCES `source_donnees` (`source_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_lot_valide_par` FOREIGN KEY (`valide_par_utilisateur_id`) REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `mesure_biometrique`
--
ALTER TABLE `mesure_biometrique`
  ADD CONSTRAINT `fk_mesure_bio_lot` FOREIGN KEY (`lot_id`) REFERENCES `lot_donnees` (`lot_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mesure_bio_source` FOREIGN KEY (`source_id`) REFERENCES `source_donnees` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mesure_bio_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `mesure_sommeil_sante`
--
ALTER TABLE `mesure_sommeil_sante`
  ADD CONSTRAINT `fk_mesure_sommeil_lot` FOREIGN KEY (`lot_id`) REFERENCES `lot_donnees` (`lot_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mesure_sommeil_source` FOREIGN KEY (`source_id`) REFERENCES `source_donnees` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mesure_sommeil_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `objectif_utilisateur`
--
ALTER TABLE `objectif_utilisateur`
  ADD CONSTRAINT `fk_objectif_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `plat`
--
ALTER TABLE `plat`
  ADD CONSTRAINT `fk_plat_lot` FOREIGN KEY (`lot_id`) REFERENCES `lot_donnees` (`lot_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_plat_source` FOREIGN KEY (`source_id`) REFERENCES `source_donnees` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_plat_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `progression_photo`
--
ALTER TABLE `progression_photo`
  ADD CONSTRAINT `fk_photo_objectif` FOREIGN KEY (`objectif_id`) REFERENCES `objectif_utilisateur` (`objectif_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_photo_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `seance_entrainement`
--
ALTER TABLE `seance_entrainement`
  ADD CONSTRAINT `fk_seance_lot` FOREIGN KEY (`lot_id`) REFERENCES `lot_donnees` (`lot_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seance_source` FOREIGN KEY (`source_id`) REFERENCES `source_donnees` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seance_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateur` (`utilisateur_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `seance_exercice`
--
ALTER TABLE `seance_exercice`
  ADD CONSTRAINT `fk_seance_exercice_exercice` FOREIGN KEY (`exercice_id`) REFERENCES `exercice` (`exercice_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_seance_exercice_seance` FOREIGN KEY (`seance_id`) REFERENCES `seance_entrainement` (`seance_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `stg_import`
--
ALTER TABLE `stg_import`
  ADD CONSTRAINT `fk_stg_lot` FOREIGN KEY (`lot_id`) REFERENCES `lot_donnees` (`lot_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `utilisateur`
--
ALTER TABLE `utilisateur`
  ADD CONSTRAINT `fk_utilisateur_organisation` FOREIGN KEY (`organisation_id`) REFERENCES `organisation` (`organisation_id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
```
