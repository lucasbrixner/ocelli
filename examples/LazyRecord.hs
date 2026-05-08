module LazyRecord where

data Position = Position
  { accountId :: String
  , amount :: Int
  , metadata :: [(String, String)]
  }
