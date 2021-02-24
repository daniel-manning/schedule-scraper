module Lib
    ( 
        xpTVSchedule,
        TVSchedule
    ) where


import Text.XML.HXT.Core

data Channel = Channel {
    channelID :: String,
    displayName :: String,
    iconSrc :: Maybe String
} deriving Show

data Programme = Programme {
    start :: String,
    stop :: String,
    channel :: String,
    title :: (String, String),
    desc :: (String, String),
    episodeNum :: Maybe (String, String)
  } deriving Show


data TVSchedule = TVSchedule {
    generatorInfoName :: String,
    sourceInfoName :: String,
    channels :: [Channel],
    programmes :: [Programme]
} deriving Show


instance XmlPickler Channel where
    xpickle = xpChannel

instance XmlPickler Programme where
    xpickle = xpProgramme

instance XmlPickler TVSchedule where
    xpickle = xpTVSchedule

xpTVSchedule :: PU TVSchedule
xpTVSchedule = xpElem "tv" $
      xpWrap ( \(g, s, c, p) ->  TVSchedule g s c p,
                \ s -> (generatorInfoName s, sourceInfoName s, channels s, programmes s)) $
      xp4Tuple (xpAttr "generator-info-name" xpText) 
               (xpAttr "source-info-name" xpText)
               (xpList xpChannel)
               (xpList xpProgramme)

xpChannel :: PU Channel
xpChannel = xpElem "channel" $
      xpWrap ( \(id, d, s) ->  Channel id d s,
                \ s -> (channelID s, displayName s, iconSrc s)) $
      xpTriple (xpAttr "id" xpText)
             (xpElem "display-name" $ xpText)
             (xpOption (xpElem "icon" $ xpAttr "src" $ xpText))

xpProgramme :: PU Programme
xpProgramme = xpElem "programme" $
      xpWrap ( \(s, st, c, t, d, ep) ->  Programme s st c t d ep,
                \ p -> (start p, stop p, channel p, title p, desc p, episodeNum p)) $
      xp6Tuple (xpAttr "start" xpText) 
               (xpAttr "stop" xpText)
               (xpAttr "channel" xpText)
               (xpElem "title" $ 
                  xpPair (xpAttr "lang" xpText)
                        xpText)
               (xpElem "desc" $ 
                  xpPair (xpAttr "lang" xpText)
                        xpText)
                (xpOption (xpElem "episode-num" $
                   xpPair (xpAttr "system" xpText)
                           xpText))