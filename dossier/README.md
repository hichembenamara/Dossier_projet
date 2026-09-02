# Dossier projet CDA — sources rédactionnelles

Ce répertoire contient le dossier projet en cours de rédaction (Phase 2 du plan), section par section, en Markdown. Le plan complet et l'ordre de rédaction sont dans `Plan_detaille_Dossier_Projet_CDA_HealthAI.md`.

## Arborescence

```
dossier/
  README.md                         ce fichier
  sections/
    01_liminaires.md                page de garde, remerciements, tableau des 11 compétences   [rédigé]
    02_contexte.md                  cadre, commanditaire, équipe et rôle, décision NestJS → FastAPI [rédigé]
    03_resume_anglais.md            résumé en anglais (à rédiger en dernier)
    04_cahier_des_charges.md        besoins, personas, exigences                                [à rédiger]
    05_gestion_de_projet.md         lots, suivi, environnement, risques                          [à rédiger]
    06_specifications_fonctionnelles.md  architecture, modèle de données, cas d'utilisation, séquences [rédigé]
    07_specifications_techniques.md choix, environnements, sécurité                               [rédigé]
    08_realisations.md              extraits de code commentés                                    [à rédiger]
    09_tests.md                     plan de tests, jeu d'essai                                    [à rédiger]
    10_deploiement.md               exploitation, CI, supervision, maintenance                    [à rédiger]
    11_veille.md                    veille sécurité                                               [à rédiger]
    12_conclusion.md                                                                              [à rédiger]
    13_annexes.md                   liste des annexes                                             [à rédiger]
  figures/
    sources/*.mmd                   sources Mermaid à donner à archify (couches, cas d'utilisation, 2 séquences, ETL, CI)
```

## Conventions

- Un fichier par section, extraits de code copiés depuis le dépôt (jamais retapés), chemin indiqué.
- Les figures sont référencées par leur numéro du plan (`*Figure 23 — …*`) avec la source archify à utiliser.
- Chaque section passe par `/humanizer-remove-ai-writing-patterns` en Phase 3, puis relecture humaine.
- Assemblage final : concaténer `sections/*.md` dans l'ordre, puis mise en page Word (Phase 4).

## Figures déjà produites avec archify (`docs/architecture/`)

- `runtime.architecture.html` → Figure 11 (architecture d'exécution)
- `mcd.html` → Figure 18 (MCD)
- `mpd-metier.architecture.html`, `mpd-pipeline.architecture.html` → Figure 20 (MPD)

## Produit en Phase 0 dans ce passage

- `backend/db/schema_v1_2026-04-25.sql` : schéma réel de la base livrée au Bloc 1 (export phpMyAdmin nettoyé, 19 tables, ENUM/DECIMAL/index/FK).
- `backend/db/migration_v2_2026-06.sql` : migration rejouable vers l'état courant (profil déclaratif, objectifs, `coach_posture_session`).
- `backend/db/schema_from_orm_reference.sql` : schéma généré depuis `models.py`, contrôle de cohérence ORM ↔ base uniquement.
- `backend/db/README.md` : ordre d'exécution.
