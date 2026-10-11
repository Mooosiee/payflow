module PayFlow.Provider where
import PayFlow.Domain

data ProviderConfig = ProviderConfig { pcHealth :: ProviderHealth, pcScriptedOutcomes :: [ProviderOutcome] }
  deriving (Eq, Show)

-- TODO: deterministic simulator for approval, decline, transient failure and timeout.
-- Tests must not rely on real network calls, random sleeps or flaky services.
simulateProviderCall :: ProviderConfig -> Int -> ProviderOutcome
simulateProviderCall = undefined
