module Database (
  connect,
  addChannels,
  addProgrammes,
  getChannelsList
) where

import Database.HDBC
import Database.HDBC.Sqlite3
import Control.Monad(when)
import Data.List
import ScheduleParser

connect :: FilePath -> IO Connection
connect fp =
  do dbh <- connectSqlite3 fp
     setupDB dbh
     return dbh

setupDB :: IConnection conn => conn -> IO ()
setupDB dbh =
  do tables <- getTables dbh
     when (not ("channels" `elem` tables)) $
        do run dbh "CREATE TABLE channels (\
                  \channelID TEXT NOT NULL PRIMARY KEY, \
                  \displayName TEXT NOT NULL,\
                  \iconSrc TEXT )" []
           return ()

     when (not ("programmes" `elem` tables)) $
        do run dbh "CREATE TABLE programmes (\
                    \start TEXT NOT NULL,\
                    \stop TEXT NOT NULL,\
                    \channel TEXT NOT NULL,\
                    \title TEXT NOT NULL,\
                    \desc TEXT NOT NULL,\
                    \episodeNum TEXT,\
                    \PRIMARY KEY (start, stop, channel))" []
           return ()

     commit dbh

addChannels :: IConnection conn => conn -> [Channel] -> IO ()
addChannels dbh channels =
    handleSql errorHandler $
      do 
          stmt <- prepare dbh "INSERT INTO channels (channelID, displayName, iconSrc) VALUES (?, ?, ?) ON CONFLICT (channelID) DO NOTHING"
          executeMany stmt $ map (\c -> [toSql (channelID c), toSql (displayName c), toSql (iconSrc c)]) channels
          commit dbh
      where errorHandler e =
              do fail $ "Error adding Channel: " ++ show e
         
addProgrammes :: IConnection conn => conn -> [Programme] -> IO ()
addProgrammes dbh programmes =
    handleSql errorHandler $
      do 
          stmt <- prepare dbh "INSERT INTO programmes (start, stop, channel, title, desc, episodeNum) VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT (start, stop, channel) DO NOTHING"
          executeMany stmt $ map (\p -> [toSql (start p), toSql (stop p), toSql (channel p), toSql (snd $ title p), toSql (snd $ desc p), toSql (snd <$> episodeNum p)]) programmes
          commit dbh
      where errorHandler e =
              do fail $ "Error adding Programme: " ++ show e


getChannelsList :: IConnection conn => conn -> IO [Channel]
getChannelsList dbh =
  handleSql errorHandler $
    do 
        r <- quickQuery' dbh "SELECT * FROM channels" []
        return $ map retrieveChannel r
    where errorHandler e =
              do fail $ "Error getting channels:\n"
                      ++ show e
          --retrieveChannel [] = []
          retrieveChannel [channelID,displayName,iconSrc] = Channel{ channelID = fromSql channelID, displayName = fromSql displayName, iconSrc = fromSql iconSrc}

