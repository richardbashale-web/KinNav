# Auth Service

## Description
API NestJS de création d'identités anonymes et de comptes par email. Les identités et comptes sont conservés en mémoire pour le MVP de développement; brancher un dépôt durable avant un déploiement.

## Technologies et structure
Node.js 20+, NestJS, JWT signé HS256 et `bcryptjs`; `src/auth/` contient contrôleur et service.

## Installation / lancement
`npm install`, puis `npm run start:dev`; Docker Compose expose le service sur le port hôte 3001.

## Tests
`npm test`.

## Variables
`PORT` (3000), `JWT_SECRET` (obligatoire, 32 caractères minimum en déploiement) et `JWT_EXPIRES_IN`.

## API
`POST /auth/anonymous` `{device_uuid}`; `/auth/register` `{email,password,display_name}`; `/auth/login` `{email,password}`. Retours : token, refresh_token et user.

## Maintenance
Équipe KinNav.
