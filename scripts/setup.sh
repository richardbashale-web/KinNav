#!/usr/bin/env sh
set -eu

command -v docker >/dev/null 2>&1 || { echo "Docker est requis." >&2; exit 1; }
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Fichier .env créé. Remplacez JWT_SECRET avant toute exposition réseau."
fi
docker compose config >/dev/null
echo "Configuration KinNav prête."
