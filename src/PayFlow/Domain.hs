{-# LANGUAGE DeriveGeneric #-}
module PayFlow.Domain where

import Data.Text (Text)
import Data.Time (UTCTime)
import GHC.Generics (Generic)

newtype PaymentId = PaymentId { unPaymentId :: Text } deriving (Eq, Ord, Show, Generic)
newtype MerchantId = MerchantId { unMerchantId :: Text } deriving (Eq, Ord, Show, Generic)
newtype IdempotencyKey = IdempotencyKey { unIdempotencyKey :: Text } deriving (Eq, Ord, Show, Generic)
newtype ProviderId = ProviderId { unProviderId :: Text } deriving (Eq, Ord, Show, Generic)

data Currency = USD | EUR | GBP | INR deriving (Eq, Ord, Show, Read, Enum, Bounded, Generic)
data PaymentMethod = Card | BankTransfer | Wallet deriving (Eq, Ord, Show, Read, Enum, Bounded, Generic)
newtype AmountMinor = AmountMinor { unAmountMinor :: Integer } deriving (Eq, Ord, Show, Generic)

data PaymentRequest = PaymentRequest
  { prMerchantId :: MerchantId
  , prAmount :: AmountMinor
  , prCurrency :: Currency
  , prMethod :: PaymentMethod
  , prIdempotencyKey :: IdempotencyKey
  } deriving (Eq, Show, Generic)

data PaymentStatus = PaymentPending | PaymentProcessing | PaymentSucceeded
  | PaymentDeclined | PaymentFailed | PaymentOutcomeUnknown
  deriving (Eq, Ord, Show, Read, Enum, Bounded, Generic)

data ProviderOutcome = ProviderApproved | ProviderDeclined Text
  | ProviderTransientFailure Text | ProviderTimedOut
  deriving (Eq, Show, Generic)

data ProviderHealth = ProviderHealth
  { phProviderId :: ProviderId
  , phEnabled :: Bool
  , phSupportsCurrencies :: [Currency]
  , phSupportsMethods :: [PaymentMethod]
  , phEstimatedLatencyMs :: Int
  , phCostBasisPoints :: Int
  , phRecentSuccessRate :: Double
  } deriving (Eq, Show, Generic)

data Payment = Payment
  { paymentId :: PaymentId
  , paymentRequest :: PaymentRequest
  , paymentStatus :: PaymentStatus
  , paymentProvider :: Maybe ProviderId
  , paymentCreatedAt :: UTCTime
  , paymentUpdatedAt :: UTCTime
  , paymentAttemptCount :: Int
  , paymentLastError :: Maybe Text
  } deriving (Eq, Show, Generic)

data ValidationError = NonPositiveAmount | AmountTooLarge | EmptyMerchantId | EmptyIdempotencyKey
  deriving (Eq, Show, Generic)

-- Add explicit JSON instances and document the public wire format.
