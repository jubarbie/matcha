module Helper exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import UserModel exposing (..)
import Msgs exposing (..)

notif : Int -> Html Msg
notif notif =
  if notif > 0 then
      span [ class "notif" ] [ text <| toString notif ]
    else
      span [] []

icon : String -> Html Msg
icon fa =
  i [ class <| fa ++ " gender-icon" ] []

genderToIcon : Maybe Gender -> Html Msg
genderToIcon g =
    case g of
        Just M ->
            icon "fas fa-mars"

        Just F ->
            icon "fas fa-venus"

        _ ->
            span [] []
