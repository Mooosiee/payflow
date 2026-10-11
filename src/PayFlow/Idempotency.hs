module PayFlow.Idempotency where
import PayFlow.Domain

data RequestFingerprint = RequestFingerprint
  { rfMerchantId :: MerchantId, rfAmount :: AmountMinor
  , rfCurrency :: Currency, rfMethod :: PaymentMethod
  } deriving (Eq, Show)
data IdempotencyDecision = FirstRequest | ReturnExisting PaymentId | KeyPayloadConflict deriving (Eq, Show)

-- TODO: same key + same fingerprint returns existing payment;
-- same key + different fingerprint conflicts. DB must handle concurrent races.
decideIdempotency :: Maybe (RequestFingerprint, PaymentId) -> RequestFingerprint -> IdempotencyDecision
decideIdempotency = undefined
