module PayFlow.Validation where
import PayFlow.Domain

-- TODO: pure validation; amount > 0, documented maximum, non-empty bounded IDs.
validatePaymentRequest :: PaymentRequest -> Either ValidationError PaymentRequest
validatePaymentRequest = undefined
