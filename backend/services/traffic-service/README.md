# Traffic Service

## Description
API FastAPI de signalements et niveaux de trafic simplifiés. Le stockage est en mémoire et doit être remplacé par MongoDB avant la production.

## Technologies et structure
Python 3.11+, FastAPI et Pydantic; `main.py` expose l'API et les contrats validés.

## Installation / lancement
`python -m pip install -r requirements.txt`, puis `uvicorn main:app --reload`.

## Tests
`python -m pytest`.

## Variables
`PORT` (8000); aucune clé requise pour le MVP.

## API
`GET/POST /traffic/reports`, `POST /traffic/reports/{id}/vote`, `GET /traffic/segments`; OpenAPI sur `/docs`.

## Maintenance
Équipe KinNav.
