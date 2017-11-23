module Main (main) where

import qualified Control.Exception as Exception
import qualified Data.Array.IO as Array
import qualified Data.ByteString as ByteString
-- import qualified GHC.Compact as Compact

type Msg = ByteString.ByteString

msgsPerCompact = 1000
numCompacts = 200
windowSize = numCompacts * msgsPerCompact

type Chan = Array.IOArray [Msg] -- We keep `msgsPerCompact` in each list

msgCount = 1000000

message :: Int -> Msg
message n = ByteString.replicate 1024 (fromIntegral n)

pushMsg :: Array.IOArray Int [Msg] -> Int -> IO ()
pushMsg chan highId = do
    msg <- Exception.evaluate $ message highId
    let index = mod highId windowSize
    let (bucketIndex, elementIndex) = divMod index msgsPerCompact
    oldBucket <- Array.readArray chan bucketIndex
    let newBucket = if elementIndex == 0
        then msg : oldBucket
        else [msg]
    Array.writeArray chan bucketIndex newBucket

initialArray :: IO (Array.IOArray Int [Msg])
initialArray = Array.newArray (0, numCompacts) []

main :: IO ()
main = do
  c <- initialArray
  mapM_ (pushMsg c) [0..msgCount]
