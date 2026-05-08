module Main where

import Ocelli.Check
import Ocelli.Render
import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)

main :: IO ()
main = do
  args <- getArgs

  case args of
    ["check", path] -> do
      diagnostics <- checkPath path
      putStr (renderDiagnostics diagnostics)

      if null diagnostics
        then exitSuccess
        else exitFailure

    _ -> do
      putStrLn "ocelli"
      putStrLn ""
      putStrLn "Usage:"
      putStrLn "  ocelli check <path>"
      putStrLn ""
      putStrLn "Example:"
      putStrLn "  ocelli check examples/"
      exitFailure
