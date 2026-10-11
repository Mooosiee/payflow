.PHONY: build test run db-up db-down
build:
	cabal build all
test:
	cabal test all
run:
	cabal run payflow-server
db-up:
	docker compose up -d db
db-down:
	docker compose down
