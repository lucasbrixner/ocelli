module Clean where

import Data.List (foldl')
import Control.Monad.State.Strict

data Position =
  Position !String !Int

total :: [Int] -> Int
total xs =
  foldl' (+) 0 xs
