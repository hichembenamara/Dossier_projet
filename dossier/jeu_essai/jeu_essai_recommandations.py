"""Jeu d'essai du moteur de recommandations (section IX du dossier).

Exécution : depuis backend/  ->  python ../dossier/jeu_essai/jeu_essai_recommandations.py
Base SQLite en mémoire construite depuis les modèles SQLAlchemy ; aucune infrastructure requise.
"""
import json, sys
from datetime import date, datetime
from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy.orm import Session

sys.path.insert(0, ".")
from app.db.models import Base, Utilisateur, Organisation, SourceDonnees, Aliment, Exercice, MesureBiometrique, ObjectifUtilisateur
from app.schemas.recommendations import RecommendationRequest
from app.services.recommendations import RecommendationEngine

engine = create_engine("sqlite+pysqlite:///:memory:")
Base.metadata.create_all(engine)
with Session(engine) as db:
    org = Organisation(nom="HealthAI Public"); db.add(org); db.flush()
    src = SourceDonnees(nom="jeu-essai", type_source="manuel", format_source="csv", actif=True); db.add(src); db.flush()
    lea = Utilisateur(organisation_id=org.organisation_id, nom_utilisateur="lea", prenom="Léa", email="lea@example.org",
                      date_naissance=date(1997, 3, 14), genre="Femme", taille_cm=168, role="UTILISATEUR", statut="ACTIF",
                      allergies_json=json.dumps(["arachide"]), equipements_json=json.dumps(["halteres", "tapis"]),
                      contraintes_sante_json=json.dumps(["douleur genou"]), onboarding_complete=True)
    db.add(lea); db.flush()
    db.add(MesureBiometrique(utilisateur_id=lea.utilisateur_id, source_id=src.source_id,
                             mesure_le=datetime(2026, 8, 30, 8, 0), poids_kg=82.0, taille_cm=168))
    db.add(ObjectifUtilisateur(utilisateur_id=lea.utilisateur_id, type_objectif="PERTE_POIDS",
                               date_debut=date(2026, 8, 1), statut_objectif="EN_COURS", actif_unique=True))
    for nom, cat, kcal, prot, gluc, lip in [
        ("Peanut butter", "Spreads", 588, 25, 20, 50), ("Chicken breast grilled", "Poultry", 165, 31, 0, 3.6),
        ("Lentils cooked", "Legumes", 116, 9, 20, 0.4), ("Salmon baked", "Fish", 208, 20, 0, 13),
        ("Greek yogurt plain", "Dairy", 59, 10, 3.6, 0.4), ("Croissant", "Bakery", 406, 8, 46, 21),
        ("Peanut cookies", "Snacks", 475, 10, 60, 22)]:
        db.add(Aliment(source_id=src.source_id, nom=nom, categorie=cat, calories_kcal=kcal, proteines_g=prot, glucides_g=gluc, lipides_g=lip))
    for i, (nom, bp, muscle, equip) in enumerate([
        ("barbell squat", "upper legs", "quads", "barbell"), ("dumbbell lunge", "upper legs", "glutes", "dumbbell"),
        ("dumbbell bench press", "chest", "pectorals", "dumbbell"), ("pull-up", "back", "lats", "body weight"),
        ("push-up", "chest", "pectorals", "body weight"), ("dumbbell shoulder press", "shoulders", "delts", "dumbbell"),
        ("plank", "waist", "abs", "body weight"), ("cable row", "back", "upper back", "cable"),
        ("dumbbell bicep curl", "upper arms", "biceps", "dumbbell")], start=1):
        db.add(Exercice(source_id=src.source_id, external_id=f"E{i}", nom=nom, body_part_principale=bp,
                        muscle_cible_principal=muscle, equipement_principal=equip))
    db.commit()

    request = RecommendationRequest(objectif_principal="perte_poids", allergies=["arachide"],
                                    equipement_disponible=["halteres", "tapis"], contraintes_sante=["douleur genou"],
                                    niveau_sportif="debutant", frequence_seances_hebdo=3, duree_seance_min=45)
    result = RecommendationEngine().build(db, lea, request).model_dump(mode="json")

out = Path(__file__).with_name("sortie.json")
out.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
print("Contexte :", result["contexte"])
print("Nutrition :", [n["nom"] for n in result["nutrition"]])
print("Sport :", [e["nom"] for e in result["sport"]["exercices"]])
print("Messages :", result["messages"])
print("Sortie écrite dans", out)
