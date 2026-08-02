module Parser (
    parse,
    toPixel,
    Info(Info, nbrColors, limit, path, content)
    ) where

import Image
import System.Exit (exitSuccess)

data Info = Info {
  nbrColors :: Int,
  limit :: Float,
  path :: String,
  content :: String
}

split :: Char -> String -> [String]
split _ "" = []
split c s = firstWord : (split c rest)
    where firstWord = takeWhile (/=c) s
          rest = drop (length firstWord + 1) s


parse :: Maybe Info -> [String]
parse Nothing = []
parse (Just (Info n l p [])) = []
parse (Just (Info n l p f)) = split '\n' f


getPixel :: String -> Pixel
getPixel str = 
  initPixel (read (arr!!0::String) :: (Int, Int)) (read (arr!!1::String) :: (Int, Int, Int))
    where arr = split ' ' str

allFile :: [String] -> [Pixel]
allFile [] = []
allFile (x:xs) = getPixel x : allFile xs

toPixel :: Maybe Info -> [Pixel]
toPixel Nothing = []
toPixel (Just info) = allFile (parse (Just info))
