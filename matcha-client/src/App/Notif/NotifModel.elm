module App.Notif.NotifModel exposing (..)

type alias Notif =
  { type_ : NotificationType
  , to : String
  , from : String
  , notif : List String
  }

type NotificationType
    = NotifMessage
    | NotifVisit
    | NotifLike
    | NotifUnlike
