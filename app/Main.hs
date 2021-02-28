module Main where

import ScheduleParser
import Database
import Server
import Text.XML.HXT.Core
import Text.XML.HXT.HTTP

main :: IO ()
main = do
      runX $ xunpickleDocument xpTVSchedule [ withValidate no,
                                              withSubstDTDEntities no,
                                              withHTTP [],
                                              withTrace 1,
                                              withRemoveWS yes,
                                              withPreserveComment no
                                            ] "http://www.xmltv.co.uk/feed/6743"
             >>>
             processTVSchedule
      runServer
      return ()

-- the dummy for processing the unpickled data

processTVSchedule :: IOSArrow TVSchedule TVSchedule
processTVSchedule
    = arrIO $ \ x -> do
          dbh <- connect "schedule.db"
          addChannels dbh (channels x)
          addProgrammes dbh (programmes x)
          return x