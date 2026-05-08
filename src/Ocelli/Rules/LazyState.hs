module Ocelli.Rules.LazyState
  ( checkLazyState
  ) where

import Data.List (isInfixOf)
import Ocelli.Diagnostic
  ( Confidence(Heuristic)
  , Diagnostic(..)
  , DiagnosticKind(LazyStateImport) 
  )

checkLazyState :: FilePath -> String -> [Diagnostic]
checkLazyState path source =
  concatMap checkLine (zip [1 ..] (lines source))
  where
    checkLine :: (Int, String) -> [Diagnostic]
    checkLine (lineNumber, lineText)
      | importsLazyState lineText =
          [ Diagnostic
              { file = path
              , line = lineNumber
              , column = findColumn "Control.Monad" lineText
              , kind = LazyStateImport
              , confidence = Heuristic
              , message = "Lazy State imported. Lazy state can accumulate thunks when state is repeatedly updated."
              , suggestion = Just "Consider Control.Monad.State.Strict or Control.Monad.Trans.State.Strict for strict state accumulation."
              }
          ]
      | otherwise =
          []

importsLazyState :: String -> Bool
importsLazyState text =
  not (isCommentOnly text)
    && "import " `isInfixOf` text
    && ( "Control.Monad.State" `isInfixOf` text
           || "Control.Monad.Trans.State" `isInfixOf` text
       )
    && not (".Strict" `isInfixOf` text)

isCommentOnly :: String -> Bool
isCommentOnly =
  startsWith "--" . dropWhile (`elem` [' ', '\t'])

startsWith :: String -> String -> Bool
startsWith prefix text =
  take (length prefix) text == prefix

findColumn :: String -> String -> Int
findColumn needle =
  go 1
  where
    go :: Int -> String -> Int
    go column rest
      | needle `startsWith` rest = column
      | null rest = 1
      | otherwise = go (column + 1) (drop 1 rest)
