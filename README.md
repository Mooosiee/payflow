# PayFlow: Payment Routing & Reliability Simulator

PayFlow is a Haskell backend that simulates payment orchestration across multiple providers. It focuses on the decisions that make payment systems hard: which provider to route to, when to retry, when **not** to retry, and what to do when the outcome is genuinely unknown.

> **Scope:** PayFlow is a simulator. It does not move real money, store card data, or connect to production payment networks. It makes no PCI or compliance claims, and it does **not** provide end-to-end exactly-once processing (see [Limitations](#limitations)).

<!-- VERIFY: delete any line in this README that is not true of your final code. -->

## What it does

- **Typed domain model.** Payment states, provider outcomes, and money (integer minor units, never floats) are Haskell ADTs and newtypes. A definite decline and an ambiguous timeout are different constructors, so they cannot be confused.
- **Pure routing.** `chooseProvider` filters disabled or incompatible providers and picks one by policy (`PreferLatency`, `PreferCost`, `Balanced`) with deterministic tie-breaks. It returns the chosen provider with a reason, or `NoEligibleProviders`.
- **Bounded retry/fallback.** `decideAfterOutcome` caps attempts, never retries a definite decline, and treats a timeout as `OutcomeUnknown` rather than falling back to another provider.
- **Idempotent creation.** A unique `(merchant_id, idempotency_key)` constraint inside a transaction makes concurrent duplicate requests resolve to one payment. Same key and same payload replays the original payment; same key and different payload returns `409`.
- **Deterministic provider simulator.** Scripted approvals, declines, transient failures and timeouts, with no network calls, random sleeps or flaky services in the test suite.
- **Typed HTTP API.** Servant endpoints with explicit JSON instances and one documented error envelope.

## Architecture

```
HTTP (Servant)  ->  validate  ->  idempotency check (Postgres txn)
                                      |
                       choose provider (pure) -> call provider (simulator)
                                      |
                       decide next step (pure) -> persist state + attempt
```

- **Pure core:** validation, routing, idempotency decision, retry/fallback rules, state transitions (`src/PayFlow/`).
- **Effects at the edges:** PostgreSQL, clock, UUID generation, provider calls, logging.
- Business decisions are pure functions so they can be tested without a database or HTTP. Pure functions do not remove distributed-systems failure modes; those are covered by the integration tests and the limitations below.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) and [`docs/DECISIONS.md`](docs/DECISIONS.md) for the data model and design trade-offs.

## Key design decisions

| Decision | Choice | Why |
|---|---|---|
| Timeout handling | Record `OutcomeUnknown`; never switch provider automatically | A timeout is not proof the payment failed; the provider may have processed it. Switching risks a duplicate charge. |
| Decline handling | No retry | A decline is a definite negative result. |
| Concurrency | DB unique constraint + transaction | In-memory checks cannot arbitrate between concurrent requests or survive restarts. |
| Money | `Integer` minor units | Avoids floating-point rounding errors. |
| Architecture | Modular monolith | No distributed infrastructure is justified by a measured need here. |

<!-- VERIFY: add the "Balanced" routing formula, weights, and tie-break order you actually implemented. -->

## API

| Method | Path | Description |
|---|---|---|
| `POST` | `/payments` | Create a payment, or replay an idempotent request |
| `GET` | `/payments/:paymentId` | Current state and attempt history |
| `GET` | `/providers` | Simulator configuration |
| `GET` | `/health` | Liveness (readiness checks the database) |

<!-- VERIFY: confirm the idempotency key is a header (e.g. Idempotency-Key) or a JSON field, and match this table and docs/API.md. -->

| Status | Meaning |
|---|---|
| `201` | New payment created |
| `200` | Idempotent replay of an existing payment |
| `400` | Validation error |
| `404` | Unknown payment |
| `409` | Same idempotency key, different payload |

Errors use one stable shape and never expose stack traces or raw SQL:

```json
{ "error": { "code": "IDEMPOTENCY_CONFLICT", "message": "..." } }
```

Full contract: [`docs/API.md`](docs/API.md).

## Running locally

Requires GHC and Cabal (see `.github/workflows/ci.yml` for the pinned versions) and Docker.

```bash
cp .env.example .env
docker compose up -d db        # PostgreSQL 16
cabal update
cabal build all
cabal test all                 # unit, property and PostgreSQL integration tests
cabal run payflow-server       # listens on :8080
```

<!-- VERIFY: run every command above on a clean checkout before publishing. -->

Example:

```bash
curl -X POST localhost:8080/payments \
  -H 'Content-Type: application/json' \
  -d '{ "merchantId": "m_1", "amount": 49900, "currency": "INR",
        "method": "Card", "idempotencyKey": "order-1001" }'
```

## Testing

- **Unit tests (Hspec):** validation boundaries, provider eligibility and tie-breaks, idempotency decisions, bounded retries, no retry on decline, timeout ambiguity.
- **Property tests (QuickCheck):** <!-- VERIFY: list the actual properties, e.g. terminal states never regress; routing is deterministic for identical inputs. -->
- **PostgreSQL integration tests:** concurrent duplicate requests with the same key produce exactly one payment row. Unit tests alone do not prove concurrent database correctness, so this one runs against a real database.
- **API tests:** JSON contract and status codes.

CI runs `cabal build all` and `cabal test all` on every push.

## Limitations

- **Simulator only.** No real providers, money, or card data. Provider behaviour is scripted and does not model every real-world failure.
- **Not exactly-once.** API-side idempotency prevents duplicate *requests* from creating duplicate payments. It does not guarantee end-to-end exactly-once execution against an external provider.
- **Unknown outcomes are not auto-reconciled.** A real integration would resolve them through the provider's status API or webhooks; PayFlow records the state and stops.
- **No load or performance testing.** No throughput or latency claims are made.
- **Routing inputs are static** simulator configuration, not live health data.

## Project status

<!-- VERIFY: keep this section truthful. List what is implemented and what is not. -->

## Build log

Real bugs found while building, with root cause, fix, and regression test, are recorded in [`docs/BUILD_LOG.md`](docs/BUILD_LOG.md).

## License

MIT