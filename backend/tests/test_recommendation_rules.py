from __future__ import annotations

from app.db.models import Exercice
from app.services.recommendations import RecommendationEngine
import json
from datetime import date, datetime
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from app.db.base import Base
from app.db.models import Aliment, MesureBiometrique, ObjectifUtilisateur, Organisation, SourceDonnees, Utilisateur
from app.schemas.recommendations import RecommendationRequest
from app.services.recommendations import NUTRITION_MIN_RELEVANCE


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
    exercice = Exercice(
        exercice_id=1,
        nom="Squat",
        body_part_principale="upper legs",
        muscle_cible_principal="quads",
    )

    contraindications = engine._exercise_contraindications(exercice, ["douleur genou"])

    assert contraindications
    assert engine._has_severe_contraindication(contraindications) is True


# --- Écarts du jeu d'essai (section IX) -----------------------------------------------------





@pytest.fixture()
def jeu_essai_db():
    """Profil et catalogues du jeu d'essai (Léa : perte de poids, arachide, haltères + tapis, genou)."""
    engine = create_engine("sqlite+pysqlite:///:memory:")
    Base.metadata.create_all(engine)
    with Session(engine) as db:
        org = Organisation(nom="HealthAI Public")
        db.add(org)
        db.flush()
        src = SourceDonnees(nom="jeu-essai", type_source="manuel", format_source="csv", actif=True)
        db.add(src)
        db.flush()
        lea = Utilisateur(
            organisation_id=org.organisation_id, nom_utilisateur="lea", email="lea@example.org",
            date_naissance=date(1997, 3, 14), genre="Femme", taille_cm=168, role="UTILISATEUR", statut="ACTIF",
            allergies_json=json.dumps(["arachide"]), equipements_json=json.dumps(["halteres", "tapis"]),
            contraintes_sante_json=json.dumps(["douleur genou"]), onboarding_complete=True,
        )
        db.add(lea)
        db.flush()
        db.add(MesureBiometrique(utilisateur_id=lea.utilisateur_id, source_id=src.source_id,
                                 mesure_le=datetime(2026, 8, 30, 8, 0), poids_kg=82.0, taille_cm=168))
        db.add(ObjectifUtilisateur(utilisateur_id=lea.utilisateur_id, type_objectif="PERTE_POIDS",
                                   date_debut=date(2026, 8, 1), statut_objectif="EN_COURS", actif_unique=True))
        for nom, cat, kcal, prot, gluc, lip in [
            ("Peanut butter", "Spreads", 588, 25, 20, 50), ("Chicken breast grilled", "Poultry", 165, 31, 0, 3.6),
            ("Lentils cooked", "Legumes", 116, 9, 20, 0.4), ("Salmon baked", "Fish", 208, 20, 0, 13),
            ("Greek yogurt plain", "Dairy", 59, 10, 3.6, 0.4), ("Croissant", "Bakery", 406, 8, 46, 21),
            ("Peanut cookies", "Snacks", 475, 10, 60, 22),
        ]:
            db.add(Aliment(source_id=src.source_id, nom=nom, categorie=cat, calories_kcal=kcal,
                           proteines_g=prot, glucides_g=gluc, lipides_g=lip))
        for i, (nom, bp, muscle, equip) in enumerate([
            ("barbell squat", "upper legs", "quads", "barbell"), ("dumbbell lunge", "upper legs", "glutes", "dumbbell"),
            ("dumbbell bench press", "chest", "pectorals", "dumbbell"), ("pull-up", "back", "lats", "body weight"),
            ("push-up", "chest", "pectorals", "body weight"), ("dumbbell shoulder press", "shoulders", "delts", "dumbbell"),
            ("plank", "waist", "abs", "body weight"), ("cable row", "back", "upper back", "cable"),
            ("dumbbell bicep curl", "upper arms", "biceps", "dumbbell"),
        ], start=1):
            db.add(Exercice(source_id=src.source_id, external_id=f"E{i}", nom=nom, body_part_principale=bp,
                            muscle_cible_principal=muscle, equipement_principal=equip))
        db.commit()
        yield db, lea


def _request() -> RecommendationRequest:
    return RecommendationRequest(
        objectif_principal="perte_poids", allergies=["arachide"], equipement_disponible=["halteres", "tapis"],
        contraintes_sante=["douleur genou"], niveau_sportif="debutant", frequence_seances_hebdo=3, duree_seance_min=45,
    )


def test_nutrition_rejects_low_score_candidates(jeu_essai_db):
    db, lea = jeu_essai_db

    result = RecommendationEngine().build(db, lea, _request())

    names = [item.nom for item in result.nutrition]
    assert "Croissant" not in names
    assert all(item.score_pertinence >= NUTRITION_MIN_RELEVANCE for item in result.nutrition)
    assert any(message.startswith("Catalogue insuffisant") for message in result.messages)


def test_session_duration_matches_exercises(jeu_essai_db):
    db, lea = jeu_essai_db

    result = RecommendationEngine().build(db, lea, _request())

    session = result.sport.seances[0]
    assert session.duree_min == sum(item.duree_min for item in session.exercices)
    assert abs(session.duree_min - 45) <= len(session.exercices)  # arrondi par exercice
