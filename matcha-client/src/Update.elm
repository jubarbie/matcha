module Update exposing (..)

import Routing exposing (parseLocation)

import Models exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        UsersResponse response ->
            ( { model | users = response }
            , Cmd.none
            )
        OnLocationChange location -> 
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )
