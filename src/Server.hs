{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Server (
  runServer
) where

import Database 
import ScheduleParser
import Database.HDBC
import Database.HDBC.Sqlite3
import Control.Monad.Trans.Class
import Control.Monad.IO.Class
import Control.Concurrent
import Servant
import Network.Wai
import Network.Wai.Handler.Warp
import System.IO
import Servant.HTML.Blaze
import qualified Text.Blaze.Html5   as H
import Text.Blaze.Html5.Attributes as A
import Data.Aeson
import GHC.Generics
import Data.Maybe

type Homepage = H.Html
type Api =
  "channels" :> Get '[JSON] [Channel] :<|>
  {--"filterChannel" :> ReqBody '[JSON] Channel :> Post '[JSON] Channel :<|>--}
  Raw


itemApi :: Proxy Api
itemApi = Proxy

runServer:: IO ()
runServer = do
 let port = 3000
     settings =
       setPort port $
       setBeforeMainLoop (hPutStrLn stderr ("listening on port " ++ show port))
       defaultSettings
 runSettings settings =<< mkApp

mkApp :: IO Application
mkApp = do
    dbh <- connect "schedule.db"
    return $ serve itemApi $ server dbh

server :: IConnection conn => conn -> Server Api
server dbh =
  getChannels :<|>
  {--filterChannel :<|>--}
  staticServer
  where
    getChannels :: Handler [Channel]
    getChannels = liftIO $ getChannelsList dbh

    {--postExpansion :: ExpansionRecord -> Handler ExpansionRecord
    postExpansion expansion = liftIO $ addExpansion dbh expansion--}

    staticServer :: ServerT Raw m
    staticServer = serveDirectoryWebApp "static-files"
    