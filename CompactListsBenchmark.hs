{-# LANGUAGE ScopedTypeVariables #-}
module Main (main) where

import qualified Control.Exception as Exception
import qualified Data.Array.IO as Array
import qualified Data.ByteString as ByteString
import Control.Monad
import qualified GHC.Compact as Compact
import Data.Char

type Msg = String

msgsPerCompact = 10000
numCompacts = 100
windowSize = numCompacts * msgsPerCompact

type Chan = Array.IOArray [Msg] -- We keep `msgsPerCompact` in each list

msgCount = 1000000

message :: Int -> Msg
message n = map chr $ replicate 1024 (fromIntegral n)

pushMsg :: Array.IOArray Int (Compact.Compact [Msg]) -> Int -> IO ()
pushMsg chan highId = do
    msg <- Exception.evaluate $ message highId
    let index :: Int = mod highId windowSize
    let (bucketIndex :: Int, elementIndex :: Int) = divMod index msgsPerCompact
    oldBucketCompact :: Compact.Compact [Msg] <- Array.readArray chan bucketIndex
    let oldBucket :: [Msg] = Compact.getCompact oldBucketCompact
    if elementIndex == 0
      then do
        let newBucket :: [Msg] = msg : oldBucket
        newBucketCompact :: Compact.Compact [Msg] <- Compact.compactAdd oldBucketCompact newBucket
        Array.writeArray chan bucketIndex newBucketCompact
      else do
        newBucketCompact :: Compact.Compact [Msg] <- Compact.compact [msg]
        Array.writeArray chan bucketIndex newBucketCompact

initialArray :: IO (Array.IOArray Int (Compact.Compact [Msg]))
initialArray = do
  arr <- Array.newArray (0, numCompacts) undefined
  let initIndex i = do
                      emptyCompact <- Compact.compact []
                      Array.writeArray arr i emptyCompact
  mapM_ initIndex [0..numCompacts-1]
  return arr

main :: IO ()
main = do
  c <- initialArray
  mapM_ (pushMsg c) [0..msgCount]
