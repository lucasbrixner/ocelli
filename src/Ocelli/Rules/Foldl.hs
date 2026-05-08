module Ocelli.Rules.Foldl
  ( checkFoldl
  ) where

import Data.List (isInfixOf)
import Ocelli.Diagnostic
  ( Confidence(Heuristic)
  , Diagnostic(..)
  , DiagnosticKind(ThunkAccumulation)
  )

checkFoldl :: FilePath -> String -> [Diagnostic]
checkFoldl path source =
  concatMap checkLine (zip [1 ..] (lines source))
  where
    checkLine :: (Int, String) -> [Diagnostic]
    checkLine (lineNumber, lineText)
      | containsSuspiciousFoldl lineText =
          [ Diagnostic
              { file = path
              , line = lineNumber
              , column = findColumn "foldl" lineText
              , kind = ThunkAccumulation
              , confidence = Heuristic
              , message = "Possible thunk accumulation via lazy foldl."
              , suggestion = Just "Use Data.List.foldl' for strict accumulation when the accumulator should be evaluated eagerly."
              }
          ]
      | otherwise =
          []

containsSuspiciousFoldl :: String -> Bool
containsSuspiciousFoldl text =
  containsFoldl
    && not containsFoldlPrime
    && not (isCommentOnly text)
  where
    containsFoldl =
      "foldl " `isInfixOf` text
        || "foldl\t" `isInfixOf` text
        || "foldl(" `isInfixOf` text
        || "foldl (" `isInfixOf` text
        || "foldl $" `isInfixOf` text

    containsFoldlPrime =
      "foldl'" `isInfixOf` text

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
