# Planned API contract

Update this document to match the implementation.

- `POST /payments`: create payment or replay an idempotent request.
- `GET /payments/:paymentId`: return current state and safe metadata.
- `GET /providers`: simulator configuration/health.
- `GET /health`: process health; add readiness if DB is checked.

Possible status choices: 201 for newly created, 200 for replay, 400 for invalid input, 409 for same key/different payload, 404 for unknown payment. Document final choices and test them.

Use a stable error shape such as `{"error":{"code":"...","message":"...","requestId":"..."}}`. Never expose stack traces or raw SQL errors. Decide whether idempotency key comes from a header or JSON; prefer one canonical source.
