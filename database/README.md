# Données KinNav

## Description
Schémas de persistance du MVP.

## Technologies / structure
PostgreSQL 16 (`postgres/`), MongoDB (`mongodb/`) et Redis (`redis/`).

## Installation / lancement
Les conteneurs de données sont définis dans `docker-compose.yml`; la migration PostgreSQL est montée en initialisation.

## Tests
Appliquer la migration à une base de test puis vérifier contraintes et index.

## Variables
`POSTGRES_*`, `MONGODB_URI`, `REDIS_URL` dans `.env.example`.

## Interfaces
Voir les tables SQL et le schéma document de signalement.

## Maintenance
Équipe KinNav.
