# MongoDB KinNav

## Description
Stockage cible des signalements et événements communautaires; le service MVP les conserve encore en mémoire.

## Technologies / structure
MongoDB 7; le schéma de validation est dans `schemas/traffic_reports.validator.json`.

## Installation / lancement
Démarrer le service MongoDB avec Docker Compose.

## Tests
Appliquer le validateur et contrôler l'index geospatial `2dsphere` dans un environnement de test.

## Variables
`MONGODB_URI`.

## Interfaces
Collection `traffic_reports`, coordonnées GeoJSON `[longitude, latitude]`.

## Maintenance
Équipe KinNav.
