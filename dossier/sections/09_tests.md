# IX. Tests

## 1. Stratégie et plan de tests

La stratégie suit la pyramide des tests : beaucoup de tests rapides et isolés sur les règles métier, une couche de tests de contrat sur l'API, et des parcours manuels de bout en bout sur l'interface, tracés dans un tableau. Les tests automatisés sont exécutés à chaque `push` par GitHub Actions ; un échec bloque la fusion.

*Figure 32 — Plan de tests (tableau Word).*

| Niveau | Périmètre | Outil | Nombre | Quand |
|---|---|---|---|---|
| Unitaire | Règles du moteur de recommandations (allergènes, matériel, contraintes de santé) | pytest | 3 | CI |
| Unitaire | Logique du coach posture (comptage des répétitions, maintien statique) | pytest | 2 | CI |
| Unitaire | Fonctions de normalisation de l'ETL (tension, durées, genre, hachage) | pytest | 5 | CI |
| Contrat API | Authentification, inscription, profil, tableaux de bord, pagination, cloisonnement par rôle et par utilisateur, analyse de repas, recommandations, coach posture, `/health`, OpenAPI | pytest + `TestClient` FastAPI | 29 | CI |
| Manuel, bout en bout | Parcours utilisateur, administrateur et super-administrateur ; mode dégradé ; sauvegarde et restauration | navigateur, Docker Compose | 10 cas | avant chaque soutenance |
| Jeu d'essai | Moteur de recommandations sur un profil de référence | script Python sur base SQLite | 1 scénario | ce dossier |

Le total de 39 tests automatisés a été vérifié le 2 septembre 2026 : `pytest -q` renvoie `34 passed` dans `backend/tests` et `5 passed` dans `healthai_etl/tests`.

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

*Figure 33 — Exécution de la CI GitHub Actions : deux jobs verts, `backend-tests` et `frontend-build` (capture `dossier/figures/captures/fig33_github_actions_checks.png`), et sortie de `pytest -q`.*

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
| M1 | Inscription puis onboarding d'un nouvel utilisateur | Compte créé, profil déclaratif enregistré, redirection vers le tableau de bord | Conforme |
| M2 | Connexion, attente de l'expiration du jeton d'accès, navigation | Rafraîchissement transparent, aucune déconnexion | Conforme |
| M3 | Utilisateur tape `/admin/dashboard` dans l'URL | Redirection vers `/me/dashboard` ; l'API répond 403 si appelée directement | Conforme |
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
