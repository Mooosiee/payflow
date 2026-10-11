module PayFlow.Persistence where

-- TODO: migrations and repository functions for payments, idempotency records,
-- and payment_attempts. Enforce unique (merchant_id, idempotency_key), use a
-- transaction for create/replay decisions, and add PostgreSQL integration tests.
-- Unit tests alone do not prove concurrent database correctness.
