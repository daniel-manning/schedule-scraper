module Main where

import Lib
import Text.XML.HXT.Core

main :: IO ()
main = do
      runX $ xunpickleDocument xpTVSchedule [ withValidate no,
                                              withSubstDTDEntities no,
                                              withTrace 1,
                                              withRemoveWS yes,
                                              withPreserveComment no
                                            ] "resource/6743.xml"
             >>>
             processTVSchedule
      return ()

-- the dummy for processing the unpickled data

processTVSchedule :: IOSArrow TVSchedule TVSchedule
processTVSchedule
    = arrIO ( \ x -> do {print x ; return x})