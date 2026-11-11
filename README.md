# KinNav

KinNav est un MVP d'aide à la navigation communautaire à Kinshasa. Le dépôt regroupe le client Flutter, les services API, les schémas de données et les éléments de déploiement local.

## Technologies

- Flutter / Dart pour l'application mobile.
- NestJS et TypeScript pour l'authentification.
- Go pour le calcul d'itinéraires A* sur un graphe routier fourni.
- Python / FastAPI pour le trafic et les signalements.
- PostgreSQL, MongoDB, Redis et Docker Compose.

## Structure

- `mobile/` : client mobile Flutter.
- `backend/` : passerelle Nginx et services API.
- `database/` : migration PostgreSQL et documentation des données.
- `infrastructure/` : configuration de monitoring et de conteneurs.
- `docs/` : contrats d'API et architecture.
- `scripts/` : aides de développement.

## Démarrage local

1. Copier `.env.example` vers `.env` et remplacer les secrets de développement.
2. Installer Docker et Docker Compose.
3. Lancer `docker compose up --build`.
4. Les services sont accessibles via `http://localhost:8080/api/v1`.

Le service de routage démarre sans graphe mais renvoie `503` pour les itinéraires. Il accepte un graphe JSON compatible documenté dans `backend/services/routing-service/README.md`; il n'extrait pas lui-même un fichier PBF. Définir `ROUTING_GRAPH_PATH` vers le fichier monté sous `/data`. En production, utiliser une clé JWT forte. Les données de trafic, profils et comptes du MVP sont en mémoire et sont réinitialisées au redémarrage.

## Commandes

- `make test` : tests Flutter, Go, Python et Node (si les dépendances sont installées).
- `make dev` : démarre l'infrastructure de données locale.
- `make build` : construit les images Docker et l'APK Android.
- `cd admin-panel && npm install && npm run dev` : démarre la console en lecture seule.

## Variables

Voir `.env.example`. Ne jamais stocker de secrets réels dans le dépôt.

## État du MVP

Auth anonyme et email, calcul A* sur graphe fourni, API de signalements, gestion de profil de développement, carte mobile et console de consultation sont les parcours initiaux. L'app mobile ne consomme pas encore les API de recherche/routage/alertes, et ses écrans Résultats/Navigation restent informatifs. Firebase, paiements, tuiles hors ligne, géocodage, données routières OSM, stockage durable, limite anonyme de trois itinéraires par jour, modération et IA/ML sont des intégrations ultérieures; les guides précisent ces limites.

## Maintenance

Mainteneurs : équipe KinNav. Les contrats et instructions de chaque module sont décrits dans leurs README respectifs.
