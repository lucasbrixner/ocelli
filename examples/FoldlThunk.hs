module FoldlThunk where

total :: [Int] -> Int
total xs =
  foldl (+) 0 xs
