module Ocelli.Diagnostic
  ( Confidence(..)
  , DiagnosticKind(..)
  , Diagnostic(..)
  ) where

data Confidence
  = Heuristic
  | GHCInferred
  | RuntimeObserved
  | Proven
  deriving (Eq, Show)

data DiagnosticKind
  = ThunkAccumulation
  | LazyRecordFields
  | LazyStateImport
  deriving (Eq, Show)

data Diagnostic = Diagnostic
  { file       :: FilePath
  , line       :: Int
  , column     :: Int
  , kind       :: DiagnosticKind
  , confidence :: Confidence
  , message    :: String
  , suggestion :: Maybe String
  }
  deriving (Eq, Show)
