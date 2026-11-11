# User Service

## Description
Service NestJS minimal de profil, historique et favoris pour le MVP. Les données sont temporaires en mémoire; la migration PostgreSQL est fournie dans `database/postgres`.

## Technologies / structure
Node.js 20+, NestJS et validation TypeScript; `src/main.ts` expose le contrôleur `users`.

## Installation / lancement
`npm install`, puis `npm run start:dev`; port 3002 par défaut.

## Tests
`npm test`.

## Variables
`PORT` (3002) et `JWT_SECRET` (doit correspondre au service auth).

## API
Toutes les routes demandent `Authorization: Bearer <token>` : `GET/PATCH /users/me`, `GET /users/me/history?page=&limit=`, `POST /users/me/favorites`, `DELETE /users/me/favorites/:id`.

## Maintenance
Équipe KinNav.
