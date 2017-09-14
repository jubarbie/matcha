module Main exposing (..)

import Json.Decode exposing (..)
import Navigation exposing (Location)
import Routing exposing (..)

import Views exposing (view)
import Models exposing (..)
import Update exposing (..)
import Commands exposing (..)
import Ports exposing (getToken, tokenRecieved)


initialModel : Route -> Model
initialModel route =
    { route = route
    , token = Nothing
    , loginInput =  {input = "", value = "", validation = (False, "")}
    , passwordInput =  {input = "", value = "", validation = (False, "")} 
    , users = []
    , message = Nothing
    }

init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location
        cmd = case currentRoute of
            Members -> Cmd.none
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
