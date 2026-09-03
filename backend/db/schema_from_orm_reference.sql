-- HealthAI Coaching — schéma MariaDB 10.11 (généré depuis backend/app/db/models.py, SQLAlchemy 2.0)
-- Schéma seul, sans données. Base : healthai_coaching
SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE IF NOT EXISTS organisation (
	organisation_id INTEGER NOT NULL AUTO_INCREMENT, 
	nom VARCHAR(255) NOT NULL, 
	adresse TEXT, 
	image_path VARCHAR(500), 
	cree_le DATETIME, 
	PRIMARY KEY (organisation_id), 
	UNIQUE (nom)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS regle_qualite (
	regle_id INTEGER NOT NULL AUTO_INCREMENT, 
	entite VARCHAR(80) NOT NULL, 
	nom_champ VARCHAR(120), 
	code_regle VARCHAR(120) NOT NULL, 
	type_regle VARCHAR(80), 
	severite VARCHAR(30), 
	description TEXT, 
	actif BOOL NOT NULL, 
	PRIMARY KEY (regle_id), 
	CONSTRAINT uq_regle_qualite_code UNIQUE (code_regle)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS source_donnees (
	source_id INTEGER NOT NULL AUTO_INCREMENT, 
	nom VARCHAR(255) NOT NULL, 
	description TEXT, 
	type_source VARCHAR(80), 
	format_source VARCHAR(80), 
	actif BOOL NOT NULL, 
	cree_le DATETIME, 
	PRIMARY KEY (source_id), 
	UNIQUE (nom)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS aliment (
	aliment_id INTEGER NOT NULL AUTO_INCREMENT, 
	source_id INTEGER, 
	nom VARCHAR(255) NOT NULL, 
	categorie VARCHAR(120), 
	calories_kcal FLOAT, 
	proteines_g FLOAT, 
	glucides_g FLOAT, 
	lipides_g FLOAT, 
	fibres_g FLOAT, 
	sucres_g FLOAT, 
	sodium_mg FLOAT, 
	cholesterol_mg FLOAT, 
	cree_le DATETIME, 
	PRIMARY KEY (aliment_id), 
	FOREIGN KEY(source_id) REFERENCES source_donnees (source_id), 
	UNIQUE (nom)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS execution_etl (
	execution_id INTEGER NOT NULL AUTO_INCREMENT, 
	source_id INTEGER NOT NULL, 
	statut VARCHAR(40) NOT NULL, 
	demarre_le DATETIME, 
	termine_le DATETIME, 
	lignes_lues INTEGER, 
	lignes_valides INTEGER, 
	lignes_invalides INTEGER, 
	nb_doublons_supprimes INTEGER, 
	nb_valeurs_corrigees INTEGER, 
	nb_rejets INTEGER, 
	taux_qualite FLOAT, 
	message TEXT, 
	PRIMARY KEY (execution_id), 
	FOREIGN KEY(source_id) REFERENCES source_donnees (source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS exercice (
	exercice_id INTEGER NOT NULL AUTO_INCREMENT, 
	source_id INTEGER, 
	external_id VARCHAR(120), 
	nom VARCHAR(255) NOT NULL, 
	gif_180_path VARCHAR(500), 
	gif_360_path VARCHAR(500), 
	gif_720_path VARCHAR(500), 
	gif_1080_path VARCHAR(500), 
	body_part_principale VARCHAR(120), 
	muscle_cible_principal VARCHAR(120), 
	equipement_principal VARCHAR(120), 
	body_parts_json TEXT, 
	target_muscles_json TEXT, 
	secondary_muscles_json TEXT, 
	equipments_json TEXT, 
	instructions_json TEXT, 
	cree_le DATETIME, 
	PRIMARY KEY (exercice_id), 
	FOREIGN KEY(source_id) REFERENCES source_donnees (source_id), 
	UNIQUE (external_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS utilisateur (
	utilisateur_id INTEGER NOT NULL AUTO_INCREMENT, 
	organisation_id INTEGER, 
	gym_external_id VARCHAR(120), 
	sleep_external_id VARCHAR(120), 
	nom_utilisateur VARCHAR(120) NOT NULL, 
	prenom VARCHAR(120), 
	nom VARCHAR(120), 
	email VARCHAR(255), 
	date_naissance DATE, 
	genre VARCHAR(40) NOT NULL, 
	taille_cm FLOAT, 
	photo_profil_path VARCHAR(500), 
	niveau_activite VARCHAR(80), 
	niveau_sportif VARCHAR(80), 
	allergies_json TEXT, 
	regime_alimentaire VARCHAR(120), 
	preferences_alimentaires_json TEXT, 
	aliments_evites_json TEXT, 
	budget_alimentaire VARCHAR(80), 
	equipements_json TEXT, 
	contraintes_sante_json TEXT, 
	preferences_sportives_json TEXT, 
	frequence_seances_hebdo INTEGER, 
	duree_seance_min INTEGER, 
	onboarding_complete BOOL NOT NULL, 
	onboarding_complete_le DATETIME, 
	`role` VARCHAR(30) NOT NULL, 
	statut VARCHAR(30) NOT NULL, 
	mot_de_passe_hash VARCHAR(255), 
	cree_le DATETIME, 
	modifie_le DATETIME, 
	PRIMARY KEY (utilisateur_id), 
	CONSTRAINT uq_utilisateur_email UNIQUE (email), 
	CONSTRAINT uq_utilisateur_nom_utilisateur UNIQUE (nom_utilisateur), 
	CONSTRAINT uq_utilisateur_gym_external_id UNIQUE (gym_external_id), 
	CONSTRAINT uq_utilisateur_sleep_external_id UNIQUE (sleep_external_id), 
	FOREIGN KEY(organisation_id) REFERENCES organisation (organisation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS coach_posture_session (
	coach_posture_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, 
	utilisateur_id BIGINT UNSIGNED NOT NULL, 
	exercice_code VARCHAR(80) NOT NULL, 
	exercice_nom VARCHAR(120) NOT NULL, 
	type_exercice VARCHAR(20) NOT NULL, 
	statut_posture VARCHAR(40) NOT NULL, 
	score_alignement INTEGER NOT NULL, 
	reps INTEGER NOT NULL, 
	reps_in_current_set INTEGER NOT NULL, 
	sets_count INTEGER NOT NULL, 
	hold_seconds INTEGER NOT NULL, 
	best_hold_seconds INTEGER NOT NULL, 
	validated_holds INTEGER NOT NULL, 
	detected_errors_json TEXT, 
	feedback_json TEXT, 
	snapshot_path VARCHAR(500), 
	source_page VARCHAR(80) NOT NULL, 
	valide_le DATETIME NOT NULL, 
	cree_le DATETIME NOT NULL, 
	PRIMARY KEY (coach_posture_id), 
	FOREIGN KEY(utilisateur_id) REFERENCES utilisateur (utilisateur_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE INDEX ix_coach_posture_session_utilisateur_id ON coach_posture_session (utilisateur_id);

CREATE TABLE IF NOT EXISTS lot_donnees (
	lot_id INTEGER NOT NULL AUTO_INCREMENT, 
	execution_id INTEGER NOT NULL, 
	source_id INTEGER NOT NULL, 
	nom_lot VARCHAR(255) NOT NULL, 
	statut VARCHAR(40) NOT NULL, 
	cree_par_utilisateur_id INTEGER, 
	valide_par_utilisateur_id INTEGER, 
	valide_le DATETIME, 
	commentaire_validation TEXT, 
	cree_le DATETIME, 
	PRIMARY KEY (lot_id), 
	FOREIGN KEY(execution_id) REFERENCES execution_etl (execution_id), 
	FOREIGN KEY(source_id) REFERENCES source_donnees (source_id), 
	FOREIGN KEY(cree_par_utilisateur_id) REFERENCES utilisateur (utilisateur_id), 
	FOREIGN KEY(valide_par_utilisateur_id) REFERENCES utilisateur (utilisateur_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS objectif_utilisateur (
	objectif_id INTEGER NOT NULL AUTO_INCREMENT, 
	utilisateur_id INTEGER NOT NULL, 
	type_objectif VARCHAR(80) NOT NULL, 
	poids_cible_kg FLOAT, 
	date_debut DATE, 
	date_fin DATE, 
	actif_unique BOOL NOT NULL, 
	statut_objectif VARCHAR(30), 
	commentaire TEXT, 
	cree_le DATETIME, 
	PRIMARY KEY (objectif_id), 
	FOREIGN KEY(utilisateur_id) REFERENCES utilisateur (utilisateur_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS controle_qualite_donnee (
	controle_id INTEGER NOT NULL AUTO_INCREMENT, 
	execution_id INTEGER NOT NULL, 
	lot_id INTEGER, 
	regle_id INTEGER, 
	entite VARCHAR(80) NOT NULL, 
	ref_externe VARCHAR(160), 
	ref_ligne VARCHAR(160), 
	nom_champ VARCHAR(120), 
	valeur_observee TEXT, 
	valeur_corrigee TEXT, 
	payload_json TEXT, 
	niveau VARCHAR(40), 
	type_controle VARCHAR(80), 
	decision_finale VARCHAR(80), 
	est_bloquant BOOL, 
	code_controle VARCHAR(120), 
	description TEXT, 
	etape_pipeline VARCHAR(80), 
	cree_le DATETIME, 
	PRIMARY KEY (controle_id), 
	FOREIGN KEY(execution_id) REFERENCES execution_etl (execution_id), 
	FOREIGN KEY(lot_id) REFERENCES lot_donnees (lot_id), 
	FOREIGN KEY(regle_id) REFERENCES regle_qualite (regle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS enregistrement_brut (
	enregistrement_id INTEGER NOT NULL AUTO_INCREMENT, 
	lot_id INTEGER NOT NULL, 
	entite VARCHAR(80) NOT NULL, 
	ref_externe VARCHAR(160), 
	payload_json TEXT, 
	cree_le DATETIME, 
	PRIMARY KEY (enregistrement_id), 
	FOREIGN KEY(lot_id) REFERENCES lot_donnees (lot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mesure_biometrique (
	mesure_id INTEGER NOT NULL AUTO_INCREMENT, 
	utilisateur_id INTEGER NOT NULL, 
	source_id INTEGER, 
	lot_id INTEGER, 
	mesure_le DATETIME NOT NULL, 
	age_source INTEGER, 
	genre_source VARCHAR(40), 
	poids_kg FLOAT, 
	taille_cm FLOAT, 
	imc FLOAT, 
	taux_masse_grasse FLOAT, 
	bpm_repos INTEGER, 
	bpm_moyen INTEGER, 
	bpm_max INTEGER, 
	eau_l FLOAT, 
	cree_le DATETIME, 
	PRIMARY KEY (mesure_id), 
	FOREIGN KEY(utilisateur_id) REFERENCES utilisateur (utilisateur_id), 
	FOREIGN KEY(source_id) REFERENCES source_donnees (source_id), 
	FOREIGN KEY(lot_id) REFERENCES lot_donnees (lot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mesure_sommeil_sante (
	mesure_sommeil_id INTEGER NOT NULL AUTO_INCREMENT, 
	utilisateur_id INTEGER NOT NULL, 
	source_id INTEGER, 
	lot_id INTEGER, 
	mesure_le DATETIME NOT NULL, 
	person_id_source VARCHAR(120), 
	genre_source VARCHAR(40), 
	age_source INTEGER, 
	profession VARCHAR(160), 
	duree_sommeil_h FLOAT, 
	qualite_sommeil_score INTEGER, 
	activite_physique_min_jour INTEGER, 
	stress_score INTEGER, 
	categorie_imc_source VARCHAR(80), 
	tension_arterielle_brut VARCHAR(40), 
	tension_systolique INTEGER, 
	tension_diastolique INTEGER, 
	frequence_cardiaque_bpm INTEGER, 
	pas_jour INTEGER, 
	trouble_sommeil_brut VARCHAR(120), 
	trouble_sommeil_normalise VARCHAR(120), 
	cree_le DATETIME, 
	PRIMARY KEY (mesure_sommeil_id), 
	FOREIGN KEY(utilisateur_id) REFERENCES utilisateur (utilisateur_id), 
	FOREIGN KEY(source_id) REFERENCES source_donnees (source_id), 
	FOREIGN KEY(lot_id) REFERENCES lot_donnees (lot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS plat (
	plat_id INTEGER NOT NULL AUTO_INCREMENT, 
	utilisateur_id INTEGER NOT NULL, 
	source_id INTEGER, 
	lot_id INTEGER, 
	consomme_le DATETIME NOT NULL, 
	type_repas VARCHAR(80), 
	nom_plat VARCHAR(255), 
	calories_totales_kcal FLOAT, 
	cree_le DATETIME, 
	PRIMARY KEY (plat_id), 
	FOREIGN KEY(utilisateur_id) REFERENCES utilisateur (utilisateur_id), 
	FOREIGN KEY(source_id) REFERENCES source_donnees (source_id), 
	FOREIGN KEY(lot_id) REFERENCES lot_donnees (lot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS progression_photo (
	photo_id INTEGER NOT NULL AUTO_INCREMENT, 
	utilisateur_id INTEGER NOT NULL, 
	objectif_id INTEGER, 
	type_photo VARCHAR(40), 
	image_path VARCHAR(500) NOT NULL, 
	prise_le DATE, 
	cree_le DATETIME, 
	PRIMARY KEY (photo_id), 
	FOREIGN KEY(utilisateur_id) REFERENCES utilisateur (utilisateur_id), 
	FOREIGN KEY(objectif_id) REFERENCES objectif_utilisateur (objectif_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS seance_entrainement (
	seance_id INTEGER NOT NULL AUTO_INCREMENT, 
	utilisateur_id INTEGER NOT NULL, 
	source_id INTEGER, 
	lot_id INTEGER, 
	date_seance DATETIME NOT NULL, 
	type_entrainement VARCHAR(80), 
	duree_seance_min INTEGER, 
	calories_brulees_total FLOAT, 
	frequence_entrainement_j_sem INTEGER, 
	niveau_experience VARCHAR(80), 
	eau_l FLOAT, 
	cree_le DATETIME, 
	PRIMARY KEY (seance_id), 
	FOREIGN KEY(utilisateur_id) REFERENCES utilisateur (utilisateur_id), 
	FOREIGN KEY(source_id) REFERENCES source_donnees (source_id), 
	FOREIGN KEY(lot_id) REFERENCES lot_donnees (lot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS stg_import (
	stg_id INTEGER NOT NULL AUTO_INCREMENT, 
	lot_id INTEGER NOT NULL, 
	entite VARCHAR(80) NOT NULL, 
	ref_externe VARCHAR(160), 
	source_payload_json TEXT, 
	payload_normalise_json TEXT, 
	est_parseable BOOL, 
	statut_validation VARCHAR(80), 
	code_rejet_potentiel VARCHAR(120), 
	cree_le DATETIME, 
	PRIMARY KEY (stg_id), 
	FOREIGN KEY(lot_id) REFERENCES lot_donnees (lot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS journal_alimentaire (
	journal_id INTEGER NOT NULL AUTO_INCREMENT, 
	utilisateur_id INTEGER NOT NULL, 
	plat_id INTEGER, 
	aliment_id INTEGER, 
	source_id INTEGER, 
	lot_id INTEGER, 
	consomme_le DATETIME NOT NULL, 
	type_repas VARCHAR(80), 
	aliment_nom_libre VARCHAR(255), 
	quantite FLOAT, 
	unite_quantite VARCHAR(40), 
	calories_kcal FLOAT, 
	eau_ml FLOAT, 
	cree_le DATETIME, 
	PRIMARY KEY (journal_id), 
	FOREIGN KEY(utilisateur_id) REFERENCES utilisateur (utilisateur_id), 
	FOREIGN KEY(plat_id) REFERENCES plat (plat_id), 
	FOREIGN KEY(aliment_id) REFERENCES aliment (aliment_id), 
	FOREIGN KEY(source_id) REFERENCES source_donnees (source_id), 
	FOREIGN KEY(lot_id) REFERENCES lot_donnees (lot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS seance_exercice (
	seance_exercice_id INTEGER NOT NULL AUTO_INCREMENT, 
	seance_id INTEGER NOT NULL, 
	exercice_id INTEGER NOT NULL, 
	ordre_exercice INTEGER, 
	series_nb INTEGER, 
	repetitions_nb INTEGER, 
	charge_kg FLOAT, 
	duree_min FLOAT, 
	calories_brulees_estimees FLOAT, 
	commentaire VARCHAR(255), 
	cree_le DATETIME, 
	PRIMARY KEY (seance_exercice_id), 
	FOREIGN KEY(seance_id) REFERENCES seance_entrainement (seance_id), 
	FOREIGN KEY(exercice_id) REFERENCES exercice (exercice_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS=1;