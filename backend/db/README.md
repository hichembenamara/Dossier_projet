# Scripts de base de données

| Fichier | Rôle |
|---|---|
| `schema_v1_2026-04-25.sql` | Schéma de référence (19 tables), issu de la base livrée à la MSPR Bloc 1. **C'est le script de création à exécuter en premier.** |
| `migration_v2_2026-06.sql` | Évolutions de juin 2026 : profil déclaratif, objectifs, table `coach_posture_session`. À exécuter après v1. |
| `schema_from_orm_reference.sql` | Schéma généré depuis `app/db/models.py` (SQLAlchemy). Sert de contrôle de cohérence ORM ↔ base, pas de script d'installation (types simplifiés, sans ENUM ni politiques ON DELETE). |

Création d'une base vide :

```bash
mariadb -uroot -p -e "CREATE DATABASE healthai_coaching CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mariadb -uroot -p healthai_coaching < backend/db/schema_v1_2026-04-25.sql
mariadb -uroot -p healthai_coaching < backend/db/migration_v2_2026-06.sql
```
