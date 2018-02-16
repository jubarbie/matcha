module Utils exposing (..)

import Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode exposing (..)
import Msgs exposing (..)
import String
import User.UserModel exposing (..)

formatDate : Date.Date -> String
formatDate date =
    let
        year =
            toString <| Date.year date

        month =
            case Date.month date of
                Date.Jan ->
                    "jan"

                Date.Feb ->
                    "feb"

                Date.Mar ->
                    "mar"

                Date.Apr ->
                    "apr"

                Date.May ->
                    "may"

                Date.Jun ->
                    "jun"

                Date.Jul ->
                    "jul"

                Date.Aug ->
                    "aug"

                Date.Sep ->
                    "sep"

                Date.Oct ->
                    "oct"

                Date.Nov ->
                    "nov"

                Date.Dec ->
                    "dec"

        day =
            toString <| Date.day date

        h =
            toString <| Date.hour date

        m =
            toString <| Date.minute date

        s =
            toString <| Date.second date
    in
    day ++ " " ++ month ++ " " ++ year ++ " " ++ h ++ ":" ++ m ++ ":" ++ s


notif : Int -> Html Msg
notif notif =
    if notif > 0 then
        span [ class "notif" ] [ text <| toString notif ]
    else
        span [] []


icon : String -> Html Msg
icon fa =
    i [ class <| fa ] []


genderToIcon : Maybe Gender -> Html Msg
genderToIcon g =
    case g of
        Just M ->
            icon "fas fa-mars"

        Just F ->
            icon "fas fa-venus"

        _ ->
            span [] []
