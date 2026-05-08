module Ocelli.Render
  ( renderDiagnostic
  , renderDiagnostics
  ) where

import Ocelli.Diagnostic

renderDiagnostics :: [Diagnostic] -> String
renderDiagnostics diagnostics =
  case diagnostics of
    [] -> "No diagnostics found.\n"
    _  -> unlines (fmap renderDiagnostic diagnostics)

renderDiagnostic :: Diagnostic -> String
renderDiagnostic diagnostic =
  file diagnostic
    <> ":"
    <> show (line diagnostic)
    <> ":"
    <> show (column diagnostic)
    <> "\n"
    <> "  ["
    <> show (kind diagnostic)
    <> "/"
    <> show (confidence diagnostic)
    <> "] "
    <> message diagnostic
    <> renderSuggestion (suggestion diagnostic)

renderSuggestion :: Maybe String -> String
renderSuggestion maybeSuggestion =
  case maybeSuggestion of
    Nothing ->
      ""

    Just text ->
      "\n  Suggestion: " <> text
