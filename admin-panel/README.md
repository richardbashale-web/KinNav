# KinNav Admin

## Description
Tableau React de consultation des signalements récents. Il n'effectue pas encore d'actions de modération; aucun endpoint administratif sécurisé n'est exposé par le MVP.

## Technologies / structure
React, TypeScript et Vite; `src/` contient le tableau et ses styles.

## Installation
`npm install`.

## Lancement
Démarrer l'API avec Docker Compose, puis `npm run dev`. Le proxy Vite relaie `/api` vers `http://localhost:8080`.

## Tests
`npm run build` valide le typage et la compilation.

## Variables d'environnement
`VITE_API_PROXY_TARGET` (facultatif, par défaut `http://localhost:8080`).

## API
Lit `GET /api/v1/traffic/reports`.

## Maintenance
Équipe KinNav.
