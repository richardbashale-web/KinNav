.PHONY: setup dev test build

setup:
	cd mobile && flutter pub get
	cd backend/services/auth-service && npm install
	cd backend/services/user-service && npm install
	cd backend/services/routing-service && go mod tidy
	cd backend/services/traffic-service && python -m pip install -r requirements.txt
	cd admin-panel && npm install

dev:
	docker compose up -d postgres mongodb redis

test:
	cd mobile && flutter test
	cd backend/services/auth-service && npm test
	cd backend/services/user-service && npm test
	cd backend/services/routing-service && go test ./...
	cd backend/services/traffic-service && python -m pytest
	cd admin-panel && npm run build

build:
	docker compose build
	cd mobile && flutter build apk --release
