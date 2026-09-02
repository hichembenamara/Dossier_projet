# II. Présentation du contexte et du cadre du projet

## 1. Le cadre de formation

Ce projet a été réalisé au cours de la troisième année du programme Concepteur Développeur d'Applications de l'EPSI Courbevoie, entre décembre 2025 et juillet 2026. L'EPSI évalue ses apprenants par des mises en situation professionnelle reconstituées (MSPR) : un cahier des charges fictif mais réaliste est remis à une équipe de trois ou quatre étudiants, qui doit livrer une solution fonctionnelle, sa documentation et la présenter devant un jury de professionnels extérieurs à l'école.

HealthAI Coaching a servi de fil conducteur à trois MSPR successives, chacune couvrant un bloc de compétences différent. La même base de code a été enrichie d'une soutenance à l'autre, ce qui explique la forme du projet : un socle données et API, puis une couche d'intelligence artificielle, puis l'outillage de production. Les trois soutenances ont été validées.

| MSPR | Bloc évalué | Période | Soutenance | Apport principal |
|---|---|---|---|---|
| TPRE501 | Créer un modèle de données d'une solution IA | déc. 2025 → avr. 2026 | 30 avril 2026 | Pipeline ETL, base MariaDB, API FastAPI, frontend Next.js |
| TPRE502 | Développer un modèle prédictif d'une solution IA | juin 2026 | 29 juin 2026 | Analyse de repas par vision, recommandations par LLM, coach posture, MongoDB |
| TPRE601/604 | Produire et maintenir une solution IA | 24 juin → 2 juil. 2026 | 3 juillet 2026 | Intégration continue, supervision Prometheus/Grafana, sauvegarde et restauration, mode dégradé |

*Figure 2 — Frise chronologique du projet (à produire avec archify : trois jalons MSPR et les principaux repères Git).*

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
