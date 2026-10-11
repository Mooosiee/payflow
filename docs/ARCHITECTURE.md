# Architecture

## Principle
Keep business decisions pure and put side effects at explicit boundaries. Pure functions are easier to test, but they do not remove distributed-systems failure modes.

## Request flow
1. Decode and validate request.
2. Transactionally check/create idempotency record.
3. Obtain eligible providers and choose one with a pure routing function.
4. Call deterministic provider simulator.
5. Decide finish/retry/fallback/unknown outcome.
6. Persist state and attempt history.
7. Return stable response and structured logs.

## Timeout semantics
A provider decline is a known negative result. A transport timeout may be ambiguous: the provider may have processed the payment. Never blindly switch provider after an ambiguous timeout. In a real integration, the provider's idempotency and status-query contract determines safe recovery.

## Idempotency
Scope keys (for example merchant + key), compare canonical fingerprints, reuse the existing payment for same key/same payload, and return conflict for same key/different payload. A DB unique constraint plus transaction is required for races. API idempotency alone does not guarantee end-to-end exactly-once execution.

## Domain boundaries
- Pure core: validation, routing, idempotency decision, state transitions.
- Effects: clock, UUID, PostgreSQL, provider I/O, logging.
- API edge: JSON, HTTP status codes, stable error envelope.

## Data model
- `payments`: request fields, state, chosen provider, timestamps, attempt count.
- `idempotency_records`: merchant, key, canonical fingerprint, payment ID; unique merchant+key.
- `payment_attempts`: payment, provider, attempt number, outcome, duration, timestamp.

Represent money in integer minor units, not floating point.

## Routing
PreferLatency selects lowest latency; PreferCost lowest cost; Balanced needs a documented deterministic score with normalized inputs and tie-breaking. Exclude disabled/incompatible providers; return an explicit error if none qualify.
