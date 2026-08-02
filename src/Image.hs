module Image
    ( Pixel(Pixel, pos, pix_color),
    initPixel,
    Centroid(),
    Cluster(Cluster, clu_color, pixel),
    initCluster,
    trd,
    sumTwoTuple,
    sumArrayTuple,
    moyArrayTuple,
    getPixelFromArrayCluster,
    getColorFromArrayPixel,
    centroidToCluster,
    getCentroidFromArrayCluster,
    centroidMidleCalculator,
    sumArrayPixelByColor,
    calculateDistanceWithCentroid,
    bestIndex,


    pixelToCluster,
    imageToCluster,


    updateCluster,
    updateAllCluster--,
--    splitCluster,
--    splitAllClusterTabPair,
--    mySplit,
--    splitAllClusterPairTab
    ) where

import System.Environment (getArgs)
import System.Exit (exitWith, ExitCode (ExitSuccess, ExitFailure), exitSuccess)
import Text.Read
import System.Random
import Rand
import Data.Bool
import Data.List

data Pixel = Pixel {
    pos :: (Int, Int),
    pix_color :: (Int, Int, Int)
} deriving (Show)

--initPixel (x,y) (r,g,b)
initPixel :: (Int, Int) -> (Int, Int, Int) -> Pixel
initPixel p c = Pixel{
    pos = p,
    pix_color = c
}

type Centroid = (Int, Int, Int)

data Cluster = Cluster {
    clu_color :: Centroid,
    pixel :: [Pixel]
} deriving (Show)

initCluster :: (Int, Int, Int) -> Cluster
initCluster c = Cluster{
    clu_color = c,
    pixel = []
}

--Tuple
    --Triple
trd :: (Int, Int, Int) -> Int
trd (a,b,c) = c

sumTwoTuple :: (Int,Int,Int) -> (Int,Int,Int) -> (Int,Int,Int)
sumTwoTuple (t1a,t1b,t1c) (t2a,t2b,t2c) = (t1a + t2a, t1b + t2b, t1c + t2c)

    --Triple Array
sumArrayTuple :: [(Int, Int, Int)] -> (Int, Int, Int)
sumArrayTuple = foldr sumTwoTuple (0, 0, 0)

moyArrayTuple :: [(Int, Int, Int)] -> (Int, Int, Int)
moyArrayTuple [] = (0,0,0)
moyArrayTuple t@(tuple:tuples) = 
    case length t of
        0 -> (0,0,0)
        len -> (div a len :: Int, div b len :: Int, div c len :: Int)
    where (a, b, c) =  sumArrayTuple t

getPixelFromArrayCluster :: [Cluster] -> [[Pixel]]
getPixelFromArrayCluster = map pixel

getColorFromArrayPixel :: [Pixel] -> [(Int, Int, Int)]
getColorFromArrayPixel = map pix_color

--Centroid

centroidToCluster :: [Centroid] -> [Cluster]
centroidToCluster = map initCluster

getCentroidFromArrayCluster :: [Cluster] -> [Centroid]
getCentroidFromArrayCluster = map clu_color

centroidMidleCalculator :: (Int, Int, Int) -> (Int, Int, Int) -> Float
centroidMidleCalculator (clu1, clu2, clu3) (pix1,pix2,pix3) =
    sqrt (fromIntegral (v1 + v2 + v3))
        where v1 = (clu1 - pix1)^2
              v2 = (clu2 - pix2)^2
              v3 = (clu3 - pix3)^2


--Pixel
sumArrayPixelByColor :: [Pixel] -> (Int, Int, Int)
sumArrayPixelByColor [] = (0, 0, 0)
sumArrayPixelByColor (pix:Pixel{pos = p, pix_color = c}:pixs) =
    sumTwoTuple c (sumArrayPixelByColor pixs)


calculateDistanceWithCentroid :: Pixel -> [Centroid] -> [Float]
calculateDistanceWithCentroid p@Pixel {pix_color = pc}
  = map (centroidMidleCalculator pc)

bestIndex :: [Float] -> Maybe Int
bestIndex [] = Nothing
bestIndex f = elemIndex (minimum f) f


pixelInCluster :: Pixel -> Int -> [Cluster] -> [Cluster]
pixelInCluster p _ [] = []
pixelInCluster p 0 (Cluster{clu_color = cc, pixel = pix}:cxs) =
    Cluster{clu_color = cc, pixel = (p : pix)} : cxs
pixelInCluster p idx (cx:cxs) =
    cx : pixelInCluster p (idx - 1) cxs
--    Cluster{ cc, pix:[p] }:



pixelToCluster :: Pixel -> [Cluster] -> [Cluster]
pixelToCluster p c = 
    case bestIndex (calculateDistanceWithCentroid p arrTpl) of
        Nothing -> c
        Just idx -> pixelInCluster p idx c
    where arrTpl = (getCentroidFromArrayCluster c)

imageToCluster :: [Pixel] -> [Cluster] -> [Cluster]
imageToCluster [] c = c
imageToCluster (px:pxs) c = imageToCluster pxs new_c
    where new_c = pixelToCluster px c

updateCluster :: Cluster -> Cluster
updateCluster Cluster{clu_color = c, pixel = p} 
    | null p = Cluster{clu_color = (0,0,0), pixel = []}
    | otherwise = Cluster{clu_color = moyColor, pixel = []}
    where tabColor = getColorFromArrayPixel p
          moyColor = moyArrayTuple tabColor

updateAllCluster :: [Cluster] -> [Cluster]
updateAllCluster = map updateCluster