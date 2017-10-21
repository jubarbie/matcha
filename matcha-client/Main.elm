module Main exposing (..)

import Json.Decode exposing (..)
import Navigation exposing (Location)
import Routing exposing (..)

import Views exposing (view)
import Models exposing (..)
import Msgs exposing (..)
import Update exposing (..)
import Commands exposing (..)
import Ports exposing (getToken, tokenRecieved)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location
        cmd = case currentRoute of
            UsersRoute -> Cmd.none
            _ -> Cmd.none
    in
        ( initialModel currentRoute, Cmd.batch [cmd, getToken ()])

subscriptions : Model -> Sub Msg
subscriptions model =
    tokenRecieved SaveToken

main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
    { init = init
    , subscriptions = subscriptions
    , view = view
    , update = Update.update
    }
