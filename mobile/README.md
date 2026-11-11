# KinNav Mobile

## Description
Client Flutter en français pour la carte de Kinshasa, la recherche d'itinéraire, les alertes et le profil.

## Technologies / structure
Flutter 3.24+, Dart 3, flutter_map, OpenStreetMap, geolocator, flutter_bloc et go_router. Le code est dans `lib/`; les tests dans `test/`.

## Installation
Installer Flutter 3.24 ou supérieur et exécuter `flutter pub get`. Générer les dossiers natifs absents avec `flutter create --platforms=android,ios .`, puis configurer les permissions de localisation iOS/Android.

## Lancement
`flutter run`. L'URL API peut être fournie avec `--dart-define=KINNAV_API_URL=http://10.0.2.2:8080/api/v1`.

## Tests
`flutter test`.

## Variables d'environnement
`KINNAV_API_URL` est défini via `--dart-define`; OSM nécessite une connexion internet. La carte ne prétend pas disposer de tuiles hors ligne.

## Interfaces
Écrans carte, recherche, résultats, navigation, alertes et profil.

## Maintenance
Équipe KinNav.
