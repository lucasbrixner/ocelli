module LazyState where

import Control.Monad.State

increment :: State Int ()
increment =
  modify (+ 1)
