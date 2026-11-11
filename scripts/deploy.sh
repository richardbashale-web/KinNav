#!/usr/bin/env sh
set -eu

if [ ! -f .env ]; then
  echo "Créez .env depuis .env.example avant le lancement." >&2
  exit 1
fi
docker compose up --build -d
docker compose ps
