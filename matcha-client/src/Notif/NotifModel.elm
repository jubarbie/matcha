module Notif.NotifModel exposing (..)

type alias Notif =
  { type_ : NotificationType
  , to : String
  , from : String
  , notif : Int
  }

type NotificationType
    = NotifMessage
    | NotifVisit
    | NotifLike
