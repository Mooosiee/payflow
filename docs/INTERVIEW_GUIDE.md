# Interview guide: PayFlow

This is a preparation framework, not proof of implementation. Replace plans with evidence from your code, tests, and real debugging.

## 30-second explanation
“PayFlow is a Haskell backend simulator for payment orchestration. I built it to explore how routing policies interact with failure handling and idempotency. Routing and state-transition rules are pure functions, while PostgreSQL stores payment and request identity durably. Simulated providers reproduce approvals, declines, transient failures, and ambiguous timeouts. Unit and property-based tests check invariants. It is a simulator, not a real payment processor.”

## Purpose — Five Whys
1. Why build PayFlow? To model payment routing and reliability decisions.
2. Why payment routing? Provider selection and failure handling affect latency, cost, and duplicate-processing risk.
3. Why simulate providers? Failures become repeatable without credentials or external dependencies.
4. Why a pure core? Routing and transitions can be tested independently from I/O.
5. Why does that matter? It makes business rules easier to isolate and review, while integration tests still cover database and network boundaries.

## Why Haskell?
Explain the problem property, the language feature, the trade-off, and evidence:
- Problem: many explicit states and edge cases.
- Fit: algebraic data types and pattern matching represent cases clearly; pure functions make rules independently testable.
- Trade-off: learning curve and potentially verbose type errors.
- Evidence to cite: actual ADTs, pure functions, compiler errors resolved, and tests.
Do not claim Haskell guarantees correctness or prevents all runtime errors.

## Why Servant?
Typed route declarations help align endpoint and request/response types. Trade-off: type-level APIs can have a learning curve. Show an implemented endpoint and its tests.

## Why PostgreSQL?
Payment state must survive restarts; unique constraints and transactions arbitrate concurrent duplicate requests. Trade-off: schema and transaction complexity. Show the migration, constraint, transaction, and concurrency test.

## Why not an in-memory map?
It loses state on restart and cannot safely coordinate multiple processes. It is still useful as a unit-test fixture or pure decision model.

## Why not Kafka/Kubernetes/microservices?
They do not solve the first-order correctness problems here. Start with a modular monolith and local database; add infrastructure only when a measured requirement justifies it.

## Timeout question
If a provider processed the payment but your service timed out before seeing the response:
1. Timeout is not proof of failure.
2. Mark outcome unknown or reconcile through a provider status/idempotency mechanism.
3. Do not blindly send to another provider.
4. Decide based on the provider contract and new evidence.
5. Be explicit about what the simulator does not model.

## Idempotency questions
- Scope key, e.g. merchant + key.
- Fingerprint relevant request fields canonically.
- Same key/same payload: reuse original payment.
- Same key/different payload: conflict.
- Concurrent duplicates: unique DB constraint + transaction, then read existing record.
- Exactly once? No. API-side deduplication is not end-to-end exactly-once processing.

## Routing questions
How are eligible providers filtered? How are latency/cost represented? How do you normalize a balanced score? What is the tie-break? What if none qualify? How would real-time health data affect determinism?

## Haskell questions
What does `Either` represent? Why ADTs for state/outcomes? Difference between pure functions and `IO`? What is `Maybe` communicating? How does pattern matching expose missing cases? What belongs in domain vs API vs persistence?

## Five Whys for an actual bug
Do not invent an incident. Use a real bug you encountered:
1. What failed?
2. Why did the code behave that way?
3. Why did design/code allow it?
4. Why didn't tests or types catch it?
5. What change prevents recurrence?
Show the regression test and commit.

## Potential issues (possibilities, not claims)
- Haskell package/type mismatch during setup.
- JSON instances don't match documented wire format.
- Concurrent requests race on one idempotency key.
- Timeout is incorrectly treated as definite failure.
- Terminal state re-enters processing.
- Balanced score mixes milliseconds and basis points without normalization.
- Flaky tests depend on time/randomness.
- DB behavior differs from the pure model.

For each actual issue, record symptom, reproduction, root cause, fix, regression test, and lesson in `BUILD_LOG.md`.

## Resume bullet — only after implementation
“Built a Haskell payment-orchestration simulator with typed payment-state transitions, configurable provider routing, PostgreSQL-backed idempotency, bounded failure handling, and property-based tests for core invariants.”
Keep only implemented/tested clauses. Add metrics only when measured.
