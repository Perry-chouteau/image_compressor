module Lib
    ( imageCompressor
    ) where

import Parser

import System.Environment (getArgs)
import System.Exit (exitWith, ExitCode (ExitSuccess, ExitFailure), exitSuccess)
import Text.Read
import System.Random 
import Rand (generateArray ,generateTripleArray, generateArrayCentroide)
import Image
import Data.List

displayHelp :: IO ()
displayHelp = putStrLn "USAGE: ./imageCompressor -n N -l L -f F\n" >>
                putStrLn "\tN\tnumber of colors in the final image" >>
                putStrLn "\tL\tconvergence limit" >>
    putStrLn "\tF\tpath to the file containing the colors of the pixels"

isPositiveInt :: Int -> Maybe Int
isPositiveInt x | x >= 0 = Just x
                | otherwise = Nothing

isPositiveFloat :: Float -> Maybe Float
isPositiveFloat x | x >= 0 = Just x
                  | otherwise = Nothing

initArgs:: [String] -> Info -> Maybe Info
initArgs [] i = Just i
initArgs ("-n":y:ys) (Info n l p c) = readMaybe y >>= isPositiveInt >>=
  (\y -> initArgs ys (Info y l p c))
initArgs ("-l":y:ys) (Info n l p c) = readMaybe y >>= isPositiveFloat >>=
  (\y -> initArgs ys (Info n y p c))
initArgs ("-f":y:ys) (Info n l p c) = initArgs ys (Info n l y c)
initArgs _ _ = Nothing

defaultArgs :: Info
defaultArgs = Info {
  nbrColors = -1,
  limit = -1,
  path = "",
  content = ""
}

checkArgs :: Maybe Info -> Maybe Info
checkArgs Nothing = Nothing
checkArgs (Just (Info (-1) l p c)) = Nothing
checkArgs (Just (Info n (-1) p c)) = Nothing
checkArgs (Just (Info n l "" c)) = Nothing
checkArgs (Just i) = Just i


addContent :: Maybe Info -> String -> Maybe Info
addContent Nothing _ = Nothing
addContent (Just (Info n l p c)) x = Just (Info n l p x)

loop :: Float -> [Pixel] -> [Cluster] -> [Cluster]
loop l [] c = c
loop l p c@(cx@Cluster{clu_color = cc, pixel = cp}:cxs) 
    | l < convergence = loop l p (updateAllCluster cWithP)
    | otherwise = cWithP
        where cWithP = imageToCluster p c
              tabTabPixel = getPixelFromArrayCluster cWithP
              tabTabColor = map getColorFromArrayPixel tabTabPixel
              tabMoyColor = map moyArrayTuple tabTabColor
              tabTplClu = getCentroidFromArrayCluster c
              tabConv = zipWith centroidMidleCalculator tabTplClu tabMoyColor
              convergence = maximum tabConv

printArrayPixel :: [Pixel] -> IO()
printArrayPixel [] = return ()
printArrayPixel (Pixel{pos = p, pix_color = c}:pixs) =
    putStrLn (show p ++ " " ++ show c) >> printArrayPixel pixs

printCluster ::  [Cluster] -> IO ()
printCluster [] = return ()
printCluster ((Cluster{clu_color = cp, pixel = p}):cxs) =
    putStrLn "--" >> print cp >> putStrLn "-" >>
    printArrayPixel p >> printCluster cxs

imageCompressor :: IO ()
imageCompressor = do
    seed <- randomIO
    args <- getArgs
    let gen = mkStdGen seed
    if length args /= 6
        then displayHelp >> exitWith (ExitFailure 84)
    else
        case checkArgs (initArgs args defaultArgs) of
            Nothing -> putStrLn "error arguments" >> exitWith (ExitFailure 84)
            Just i@(Info n l p c) -> do 
                x <- readFile p
                let tab_p = toPixel (addContent (Just i) x)
                let tab_c = centroidToCluster (generateArrayCentroide gen n)
                let res = loop l tab_p tab_c
                printCluster res
                exitSuccess

-- readingFile :: String -> IO String
-- readingFile path =
--           try (readFile path) >>=
--       \result -> case result of
--          Left e -> pure Nothing
--          Right content -> pure $ Just content