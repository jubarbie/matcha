module Notif.NotifDecoder exposing (..)

import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Notif.NotifModel exposing (..)

notificationDecoder : Decoder Notif
notificationDecoder =
    JsonDec.succeed Notif
        |: field "message" notifTypeDecoder
        |: field "to" JsonDec.string
        |: field "from" JsonDec.string
        |: field "notif" JsonDec.int


notifTypeDecoder : Decoder NotificationType
notifTypeDecoder =
    JsonDec.string
        |> JsonDec.andThen
            (\a ->
                case a of
                    "message" ->
                        JsonDec.succeed NotifMessage

                    "visit" ->
                        JsonDec.succeed NotifVisit

                    "like" ->
                        JsonDec.succeed NotifLike

                    _ ->
                        JsonDec.fail "Notif unknown"
            )
