# Redis KinNav

## Description
Cache, sessions et pub/sub prévus; l'API de routage actuelle n'utilise pas encore Redis.

## Technologies / structure
Redis 7.

## Installation / lancement / tests
Démarrer via Docker Compose; vérifier avec `redis-cli ping`.

## Variables
`REDIS_URL`.

## Interfaces
Clés planifiées : `session:{jwt_id}`, `rate_limit:{user_id}`, `cache:routes:{hash}`. TTL planifiés : session 24 h, itinéraire 5 min.

## Maintenance
Équipe KinNav.
