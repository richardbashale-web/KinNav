# Architecture KinNav

## Description
Le MVP est un monorepo à services séparés, derrière une passerelle Nginx.

## Technologies / structure
Flutter; NestJS auth/profil; Go A*; FastAPI trafic; PostgreSQL, MongoDB et Redis sont déclarés dans Compose.

## Installation / lancement
Démarrer avec `docker compose up --build`.

## Tests
`make test`.

## Variables
Copier `.env.example` vers `.env`, puis définir les secrets.

## Interfaces
Le gateway route les API `/auth`, `/routes`, `/traffic` et `/users`.

## Limites de conception
Le stockage des services auth, profil et trafic est temporaire; le graphe routier doit être fourni. Les conteneurs PostgreSQL/MongoDB/Redis sont prêts mais ne sont pas encore reliés aux dépôts applicatifs.

## Maintenance
Équipe KinNav.
