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
