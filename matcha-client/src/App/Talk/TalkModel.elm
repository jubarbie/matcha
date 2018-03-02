module App.Talk.TalkModel exposing (..)

type alias TalksModel =
      { talks : List Talk
      , currentTalk : Maybe String
      }

type alias Talk =
      { username_with : String
      , unreadMsgs : Int
      , messages : List Message
      , new_message : String
      }

type alias Message =
      { date : String
      , message : String
      , user : String
      }

initialTalksModel =
  { talks = []
  , currentTalk = Nothing
  }
