module Ocelli.Check
  ( checkPath
  , checkFile
  ) where

import Ocelli.Diagnostic ( Diagnostic )
import Ocelli.FileDiscovery ( discoverHaskellFiles )
import Ocelli.Rules.Foldl ( checkFoldl )
import Ocelli.Rules.LazyRecord ( checkLazyRecord )
import Ocelli.Rules.LazyState ( checkLazyState )

checkPath :: FilePath -> IO [Diagnostic]
checkPath path = do
  files <- discoverHaskellFiles path
  diagnostics <- traverse checkFile files
  pure (concat diagnostics)

checkFile :: FilePath -> IO [Diagnostic]
checkFile path = do
  source <- readFile path
  pure
    ( checkFoldl path source
        <> checkLazyRecord path source
        <> checkLazyState path source
    )
