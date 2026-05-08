module Ocelli.Rules.LazyRecord
  ( checkLazyRecord
  ) where

import Data.List (isInfixOf)
import Ocelli.Diagnostic
  ( Confidence(Heuristic)
  , Diagnostic(..)
  , DiagnosticKind(LazyRecordFields)
  )

checkLazyRecord :: FilePath -> String -> [Diagnostic]
checkLazyRecord path source =
  go Nothing (zip [1 ..] (lines source))
  where
    go :: Maybe Int -> [(Int, String)] -> [Diagnostic]
    go _ [] =
      []

    go pendingDataLine ((lineNumber, lineText) : rest)
      | isCommentOnly lineText =
          go pendingDataLine rest

      | looksLikeOneLineRecordDeclaration lineText =
          makeDiagnostic lineNumber lineText : go Nothing rest

      | looksLikeDataDeclaration lineText =
          go (Just lineNumber) rest

      | "{" `isInfixOf` lineText
      , Just dataLineNumber <- pendingDataLine =
          makeDiagnostic dataLineNumber lineText : go Nothing rest

      | otherwise =
          go pendingDataLine rest

    makeDiagnostic :: Int -> String -> Diagnostic
    makeDiagnostic lineNumber lineText =
      Diagnostic
        { file = path
        , line = lineNumber
        , column = max 1 (findColumn "{" lineText)
        , kind = LazyRecordFields
        , confidence = Heuristic
        , message = "Record fields are lazy by default."
        , suggestion = Just "For performance-sensitive records, consider StrictData, selected strict fields with !, or explicit laziness where needed."
        }

looksLikeOneLineRecordDeclaration :: String -> Bool
looksLikeOneLineRecordDeclaration text =
  looksLikeDataDeclaration text
    && "{" `isInfixOf` text

looksLikeDataDeclaration :: String -> Bool
looksLikeDataDeclaration text =
  not (isCommentOnly text)
    && ( "data " `isInfixOf` text
           || "newtype " `isInfixOf` text
       )

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
