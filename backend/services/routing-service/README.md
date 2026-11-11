# Routing Service

## Description
API Go de calcul d'un itinéraire A* sur un graphe routier JSON. Le service accepte des coordonnées WGS84, respecte le sens des arêtes et applique un coût statique selon le type de route. Un itinéraire est retourné par requête.

## Technologies et structure
Go 1.23+, bibliothèque standard; `algorithms/` contient A*, `handlers/` l'API et `models/` les contrats.

## Installation / lancement
`go test ./...`; `go run .`. Définir `GRAPH_PATH` vers un graphe JSON. Docker Compose monte `backend/services/routing-service/data`.

## Tests
`go test ./...`.

## Variables
`PORT` (8081), `GRAPH_PATH` (facultatif, sans graphe la santé fonctionne mais l'optimisation retourne 503).

## API
`POST /routes/optimize` avec `origin` et `destination`; `GET /health`. Le fichier contient `nodes: [{id,lat,lng}]` et `edges: [{from,to,road_name,road_type}]`. Une arête est dirigée; les routes à double sens doivent fournir deux arêtes opposées. Un graphe routier dérivé d'OSM doit être généré et fourni séparément.

## Maintenance
Équipe KinNav.
