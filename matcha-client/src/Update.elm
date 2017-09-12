module Update exposing (..)

import Routing exposing (parseLocation)
import Models exposing (..)
import Commands exposing (sendLogin)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        UsersResponse response ->
            ( { model | users = response }
            , Cmd.none
            )
        HttpResponse response ->
            ( { model | route = Members } 
            , Cmd.none
            )
        OnLocationChange location -> 
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )
        
        UpdateLoginInput value ->
            let
                input = Input value value (True, "")
            in
            ( { model | loginInput = input }, Cmd.none)
        
        UpdatePasswordInput value ->
            let
                input = Input value value (True, "")
            in
            ( { model | passwordInput = input }, Cmd.none)


        SendLogin ->
            let
                login = model.loginInput.value
                pwd = model.passwordInput.value
            in
                (model, sendLogin login pwd)

