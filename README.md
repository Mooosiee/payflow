# PayFlow — Functional Payment Routing and Reliability Engine

**Starter scaffold, not a finished runnable app.** TODOs are intentional; do not claim features are implemented until you build and test them.

PayFlow simulates payment orchestration across multiple payment providers. It explores provider routing, typed payment states, idempotency, bounded retries, ambiguous outcomes, persistence, and testing. It does not move real money or connect to real payment networks.

## Stack
- Haskell (GHC/Cabal): typed domain model and pure business logic
- Servant: typed HTTP API
- PostgreSQL: durable payment/idempotency state
- Hspec + QuickCheck: example and property-based tests
- Docker Compose: local PostgreSQL

## Non-goals for v1
Real payment integrations, PCI/compliance claims, Kafka, Kubernetes, microservices, frontend, or claims of end-to-end exactly-once processing.

## Planned endpoints
- `POST /payments`
- `GET /payments/:paymentId`
- `GET /providers`
- `GET /health`

## Intended local setup
```bash
cp .env.example .env
docker compose up -d db
cabal update
cabal build all
cabal test all
cabal run payflow-server
```
The commands may need adjustment after package versions and implementation are verified.

## Suggested workflow
Read `docs/ARCHITECTURE.md`, then follow `docs/IMPLEMENTATION_PLAN.md`. Give `docs/LLM_BUILD_PROMPT.md` to your coding LLM with the repository. Build incrementally and run tests after each phase.

**Interview honesty:** this scaffold documents intended design, not completed work. Record real bugs and fixes in `docs/BUILD_LOG.md`. Do not invent challenges you did not experience.
