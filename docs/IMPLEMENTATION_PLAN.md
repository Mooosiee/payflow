# Implementation plan

## Phase 0 — toolchain and decisions
Pin compatible GHC/Cabal/package versions; choose one persistence library; define JSON conventions. Exit: build and test runner work.

## Phase 1 — pure core
Implement validation, routing, idempotency decision rules, transitions, and Hspec/QuickCheck tests. Exit: pure tests pass without DB/HTTP.

## Phase 2 — provider simulator
Script approvals, declines, transient failures, timeouts, and (if useful) timeout-after-approval. Exit: deterministic tests cover each outcome.

## Phase 3 — persistence
Add migrations, repository layer, unique idempotency constraint, transactional create/replay behavior, attempt history, and concurrent integration tests.

## Phase 4 — API
Implement Servant endpoints, explicit JSON instances, stable errors, validated configuration, health/readiness checks.

## Phase 5 — orchestration
Wire persistence, routing, simulator, retry rules, transitions, and attempt history. Test success and failure paths end to end.

## Phase 6 — observability and CI
Add safe structured logs, CI build/test, reproducible setup, and limitations. Never log secrets or raw idempotency keys.

## Phase 7 — interview preparation
Record real bugs in BUILD_LOG, document alternatives in DECISIONS, and tie every answer to source code and a passing test.
