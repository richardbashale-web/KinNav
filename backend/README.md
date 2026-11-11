# Backend KinNav

## Description
Services API du MVP et routage Nginx sous `/api/v1`.

## Technologies
NestJS/TypeScript, Go, FastAPI/Python, Nginx, Redis, PostgreSQL et MongoDB.

## Structure
`gateway/` configure les routes; `services/` contient auth, profil, routage et trafic; `shared/` réserve les contrats communs.

## Installation et lancement
Depuis la racine : `docker compose up --build`. Pour développer chaque service, suivre le README de son dossier.

## Tests
`make test`.

## Variables
`JWT_SECRET`, `JWT_EXPIRES_IN`, `PORT` et `GRAPH_PATH`; les services de données sont définis dans `.env.example`.

## Interfaces
`POST /api/v1/auth/{anonymous,register,login,refresh}`, `POST /api/v1/routes/optimize`, `GET/POST /api/v1/traffic/reports`, `POST /api/v1/traffic/reports/{id}/vote`, `GET /api/v1/traffic/segments`.

## Maintenance
Mainteneurs : équipe KinNav.
