# Infrastructure KinNav

## Description
Configuration de déploiement et d'observabilité.

## Technologies / structure
Docker Compose à la racine; répertoires `terraform/`, `kubernetes/` et `monitoring/`.

## Installation / lancement
Installer Docker Compose et lancer `docker compose up --build` à la racine.

## Tests
Valider la configuration avec `docker compose config`.

## Variables
Voir `.env.example`; les valeurs de développement ne sont pas adaptées à la production.

## API
Le gateway publie l'API sur le port 8080.

## Maintenance
Équipe KinNav.
