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
