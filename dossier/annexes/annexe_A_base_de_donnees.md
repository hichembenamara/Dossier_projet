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
