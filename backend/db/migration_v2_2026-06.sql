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
