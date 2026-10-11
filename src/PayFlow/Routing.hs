module PayFlow.Routing where
import PayFlow.Domain

data RoutingPolicy = PreferLatency | PreferCost | Balanced deriving (Eq, Show, Read)
data RoutingDecision = RoutingDecision { rdProvider :: ProviderId, rdReason :: String } deriving (Eq, Show)
data RoutingError = NoEligibleProviders deriving (Eq, Show)

-- TODO: filter disabled/incompatible providers; deterministic policies and tie-breaks.
-- Balanced must document normalized inputs/weights; return a useful decision reason.
chooseProvider :: RoutingPolicy -> PaymentRequest -> [ProviderHealth] -> Either RoutingError RoutingDecision
chooseProvider = undefined
