module PayFlow.Engine where
import PayFlow.Domain

data RetryPolicy = RetryPolicy { maxAttempts :: Int, retryTransientFailures :: Bool, allowFallbackAfterTransientFailure :: Bool }
  deriving (Eq, Show)
data EngineDecision = Finish PaymentStatus | RetrySameProvider | TryFallbackProvider | MarkOutcomeUnknown
  deriving (Eq, Show)

-- TODO: no retries for definite declines; bound attempts; treat timeout as ambiguous;
-- terminal states must not regress to processing.
decideAfterOutcome :: RetryPolicy -> PaymentStatus -> ProviderOutcome -> Int -> EngineDecision
decideAfterOutcome = undefined
