module Update exposing (..)

import Routing exposing (parseLocation)
import RemoteData exposing (..)
import Models exposing (..)
import Navigation exposing (..)
import Commands exposing (sendLogin, getUsers)
import Ports exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        UsersResponse response ->
            case Debug.log "UserResponse" response of
                Success users -> 
                    ( { model | users = users }
                    , Cmd.none )
                _ -> 
                    ( model
                    , Navigation.newUrl "/#/login" )

        LoginResponse response -> 
            case Debug.log "response" response of
                Success rep ->
                    case rep.status of
                        "success" ->
                            let cmd = case rep.token of
                                Just t -> storeToken t
                                _ -> Cmd.none
                            in
                            ( { model | token = rep.token}
                            , Cmd.batch [ Navigation.newUrl "/#/users", cmd]
                            )
                        _->
                            ( { model | message = rep.message }, Navigation.newUrl "/#/login")
                _ ->
                    ( model 
                    , Navigation.newUrl "/#/login"
                    )

        Logout ->
            ( {model | token = Nothing, users = [] }, Navigation.newUrl "/#/login")
        
        SaveToken token ->
            let t = 
            case token of 
                "" -> Nothing
                _ -> Just token
            in
                (Debug.log "model after token" { model | token = t }, Navigation.newUrl "/#/users")

        OnLocationChange location -> 
            let
                newRoute =
                    parseLocation location

                cmd = case newRoute of
                    Members ->
                        let
                            token = case model.token of
                                Just t -> t
                                _ -> ""
                        in
                            getUsers <| Debug.log "sent token" token
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

