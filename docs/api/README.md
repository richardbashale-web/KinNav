# Contrats API KinNav v1

## Description
Endpoints MVP servis par le gateway à `http://localhost:8080/api/v1`.

## Technologies / structure
HTTP/JSON; réponses d'erreur standard FastAPI/NestJS et OpenAPI de trafic à `/docs`.

## Installation / lancement / tests
`docker compose up --build`; valider l'API avec `curl` ou un client HTTP.

## Variables
`JWT_SECRET`, `ROUTING_GRAPH_PATH`; voir `.env.example`.

## Auth
- `POST /auth/anonymous` `{device_uuid}`.
- `POST /auth/register` `{email,password,display_name?}`.
- `POST /auth/login` `{email,password}`.
- `POST /auth/refresh` `{refresh_token}`.

## Routage et trafic
- `POST /routes/optimize` `{origin:{lat,lng},destination:{lat,lng}}`.
- `GET /traffic/reports?lat=&lng=&radius=&type=`.
- `POST /traffic/reports` `{type,lat,lng,description,severity}`.
- `POST /traffic/reports/{id}/vote` `{vote:"confirm"|"deny"}`.
- `GET /traffic/segments?bbox=`.

## Profil
Les routes `/users/me` exigent un bearer token. CRUD profil, historique et favoris sont en mémoire.

## Maintenance
Équipe KinNav.
