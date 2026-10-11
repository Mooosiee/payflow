{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module PayFlow.API where
import Servant

-- TODO: implement POST /payments, GET /payments/:paymentId, GET /providers, /health.
-- Map domain errors to a stable documented JSON error envelope.
type PayFlowAPI = "health" :> Get '[JSON] String
payFlowAPI :: Proxy PayFlowAPI
payFlowAPI = Proxy
