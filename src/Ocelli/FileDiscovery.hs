module Ocelli.FileDiscovery
  ( discoverHaskellFiles
  ) where

import Control.Monad (filterM)
import Data.List (isSuffixOf)
import System.Directory
  ( doesDirectoryExist
  , doesFileExist
  , listDirectory
  )
import System.FilePath ((</>))

discoverHaskellFiles :: FilePath -> IO [FilePath]
discoverHaskellFiles path = do
  isFile <- doesFileExist path
  isDir <- doesDirectoryExist path

  case (isFile, isDir) of
    (True, _) ->
      pure [path | isHaskellFile path]

    (_, True) ->
      discoverInDirectory path

    _ ->
      pure []

discoverInDirectory :: FilePath -> IO [FilePath]
discoverInDirectory dir = do
  children <- listDirectory dir
  let paths = fmap (dir </>) children

  files <- filterM doesFileExist paths
  dirs <- filterM doesDirectoryExist paths

  nested <- traverse discoverInDirectory (filter (not . ignoredDirectory) dirs)

  pure (filter isHaskellFile files <> concat nested)

isHaskellFile :: FilePath -> Bool
isHaskellFile path =
  ".hs" `isSuffixOf` path
    || ".lhs" `isSuffixOf` path

ignoredDirectory :: FilePath -> Bool
ignoredDirectory path =
  lastPathComponent path `elem`
    [ "dist-newstyle"
    , "dist"
    , ".stack-work"
    , ".git"
    , ".hie"
    ]

lastPathComponent :: FilePath -> FilePath
lastPathComponent =
  reverse . takeWhile (/= '/') . reverse
