# PostgreSQL KinNav

## Description
Schéma des comptes, historiques de trajets et favoris.

## Technologies / structure
PostgreSQL 16; `migrations/` et `seeds/`.

## Installation / lancement
Docker Compose applique automatiquement les migrations initiales.

## Tests
Vérifier la migration avec PostgreSQL 16 avant de déployer.

## Variables
`POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`.

## Interfaces
Tables `users`, `routes`, `favorites`.

## Maintenance
Équipe KinNav.
