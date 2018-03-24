module Utils exposing (..)

import App.User.UserModel exposing (..)
import Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed exposing (..)
import Http
import Json.Decode exposing (..)
import Msgs exposing (..)
import String
import Task
import Time


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


now : Cmd Msg
now =
    Task.perform (Just >> SetCurrentTime) Time.now


notif : Int -> Html Msg
notif notif =
    if notif > 0 then
        div [ class "notif" ] [ text <| toString notif ]
    else
        div [] []


icon : String -> Html Msg
icon fa =
    i [ class fa ] []


genderToIcon : Maybe Gender -> Html Msg
genderToIcon g =
    case g of
        Just M ->
            Html.Keyed.node "male" [ class "fas fa-mars" ] []

        Just F ->
            Html.Keyed.node "female" [ class "fas fa-venus" ] []

        Just NB ->
            Html.Keyed.node "non-binary" [ class "fas fa-transgender-alt" ] []

        Just O ->
            Html.Keyed.node "other" [ class "fas fa-genderless" ] []

        _ ->
            span [] []
