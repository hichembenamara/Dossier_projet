# Dossier projet CDA — sources rédactionnelles

Ce répertoire contient le dossier projet en cours de rédaction (Phase 2 du plan), section par section, en Markdown. Le plan complet et l'ordre de rédaction sont dans `Plan_detaille_Dossier_Projet_CDA_HealthAI.md`.

## Arborescence

```
dossier/
  README.md                         ce fichier
  sections/                         les 13 sections du dossier, toutes rédigées (Phase 2 terminée)
    01_liminaires.md                page de garde, remerciements, tableau des 11 compétences
    02_contexte.md                  cadre, commanditaire, équipe et rôle, décision NestJS → FastAPI
    03_resume_anglais.md            résumé en anglais (~340 mots, à réduire si l'EPSI impose 250)
    04_cahier_des_charges.md        contexte, objectifs, périmètre exclu, personas, 24 exigences
    05_gestion_de_projet.md         3 lots réels, chronologie Git, équipe, environnement, 10 risques
    06_specifications_fonctionnelles.md  architecture, 20 tables, schéma réel, cas d'utilisation, séquences
    07_specifications_techniques.md choix comparés, environnements, Dockerfile, grille OWASP
    08_realisations.md              extraits de code 7 à 23 commentés
    09_tests.md                     plan de tests, tests manuels, jeu d'essai exécuté (3 écarts)
    10_deploiement.md               exploitation, CI, supervision, maintenance corrective et évolutive
    11_veille.md                    veille en 3 axes, audits réels du 02/09/2026, décisions tracées
    12_conclusion.md                satisfactions, difficultés, perspectives, apport personnel
    13_annexes.md                   liste des 11 annexes, sources et pagination estimée
  annexes/
    annexe_A_base_de_donnees.md     contrôle de cohérence ORM ↔ base
  jeu_essai/
    jeu_essai_recommandations.py    script exécutable (depuis backend/), reproduit la section IX
    sortie.json                     sortie réelle du 02/09/2026
    pytest_*_2026-09-02.txt         sorties de pytest (34 + 5 tests)
  veille/
    pip-audit_2026-09-02.txt, npm-audit_2026-09-02.txt   sorties brutes des audits
  figures/
    sources/*.mmd                   sources Mermaid (référence de topologie)
    archify/                        24 figures archify : JSON validé (showcase), HTML livré, PNG 2x + build.sh
      fig02 05 07 09 10 11 12 13 14 14b 14c 15 15b 15c 17 19a 19b 20a 20b 21 22 23 24 30 39 ; fig18_mcd = page HTML dédiée + PNG
      (les sidecars *.visual-check.* sont régénérables et ignorés par git)
    captures/                       captures d'écran : capture.py (Playwright, stack docker locale) + PNG
      fig28 admin contrôles qualité · fig31 403 admin · fig38 /health · fig41 journal IA   (Playwright, 03/09/2026)
      fig16 maquette dashboard · fig27 recommandations sport · fig33 GitHub Actions · fig40 Grafana   (banque bloc 3/4)
```

## Conventions

- Un fichier par section, extraits de code copiés depuis le dépôt (jamais retapés), chemin indiqué.
- Les figures sont référencées par leur numéro du plan (`*Figure 23 — …*`) avec le chemin du PNG à insérer. Reste à produire : figure 29 (MongoDB Compass), tableaux Word.
- Regénérer une figure archify : `dossier/figures/archify/build.sh <type> <nom>` ; les captures Playwright : `backend/.venv/bin/python dossier/figures/captures/capture.py`.
- Chaque section passe par `/humanizer-remove-ai-writing-patterns` en Phase 3, puis relecture humaine.
- Assemblage final : concaténer `sections/*.md` dans l'ordre, puis mise en page Word (Phase 4).

## Produit en Phase 0 dans ce passage

- `backend/db/schema_v1_2026-04-25.sql` : schéma réel de la base livrée au Bloc 1 (export phpMyAdmin nettoyé, 19 tables, ENUM/DECIMAL/index/FK).
- `backend/db/migration_v2_2026-06.sql` : migration rejouable vers l'état courant (profil déclaratif, objectifs, `coach_posture_session`).
- `backend/db/schema_from_orm_reference.sql` : schéma généré depuis `models.py`, contrôle de cohérence ORM ↔ base uniquement.
- `backend/db/README.md` : ordre d'exécution.
