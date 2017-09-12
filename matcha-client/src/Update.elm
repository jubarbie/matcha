module Update exposing (..)

import Routing exposing (parseLocation)
import RemoteData exposing (..)
import Models exposing (..)
import Navigation exposing (..)
import Commands exposing (sendLogin, getUsers)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        UsersResponse response ->
            case response of
                Success users -> 
                    ( { model | users = users }
                    , Cmd.none )
                _ -> 
                    ( model
                    , Navigation.newUrl "/#/login" )
        
        HttpResponse response ->
            case Debug.log "response" response of
                Success rep ->
                    case rep.status of
                        "success" -> 
                            ( model
                            , Navigation.newUrl "/#/users"
                            )
                        _->
                            ( { model | message = rep.message }, Navigation.newUrl "/#/login")
                _ ->
                    ( model 
                    , Navigation.newUrl "/#/login"
                    )
        
        OnLocationChange location -> 
            let
                newRoute =
                    parseLocation location

                cmd = case newRoute of
                    Members -> getUsers
                    _ -> Cmd.none
            in
                ( { model | route = newRoute }, cmd )
        
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

