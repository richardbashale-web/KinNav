# Gateway KinNav

## Description
Nginx distribue les endpoints `/api/v1` vers les services du MVP.

## Technologies et structure
Nginx; `nginx.conf` définit les upstreams et limites de débit.

## Installation, lancement et tests
Lancé par Docker Compose (`docker compose up gateway`). Vérifier avec `curl http://localhost:8080/health`.

## Variables d'environnement
Aucune; les noms DNS suivent les services Compose.

## API / interfaces
Proxy `/auth/` vers Auth, `/routes/` vers Routing et `/traffic/` vers Traffic.

## Maintenance
Équipe KinNav.
