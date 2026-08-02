module Rand
    ( generateArray,
      generateTripleArray,
      generateArrayCentroide
    ) where

import System.Exit (exitWith, ExitCode (ExitSuccess, ExitFailure), exitSuccess)
import System.Random

generateArray :: StdGen -> Int -> [Int]
generateArray gen 0 = []
generateArray gen n = (res :: Int) : generateArray newgen (n - 1)
    where (res, newgen) =  randomR (0,255) gen

generateTripleArray :: StdGen -> Int -> [Int]
generateTripleArray gen n = generateArray gen (n * 3)

generateCentroide :: StdGen -> (StdGen, (Int,Int,Int))
generateCentroide g1 = (g4, (r1, r2, r3))
    where (r1, g2) =  randomR (0,255) g1
          (r2, g3) =  randomR (0,255) g2
          (r3, g4) =  randomR (0,255) g3

generateArrayCentroide :: StdGen -> Int -> [(Int, Int, Int)]
generateArrayCentroide gen 0 = []
generateArrayCentroide gen n = tpl : generateArrayCentroide newgen (n - 1)
    where (newgen, tpl) = generateCentroide gen