module Update exposing (..)

import App.AppModels exposing (..)
import App.AppUpdate exposing (updateApp)
import App.Talk.TalkCommands exposing (..)
import App.Talk.TalkModel exposing (..)
import App.User.UserCommands exposing (..)
import App.User.UserModel exposing (..)
import FormUtils exposing (..)
import Login.LoginCommands exposing (..)
import Login.LoginModels exposing (..)
import Login.LoginUpdate exposing (updateLogin)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Ports exposing (..)
import RemoteData exposing (..)
import Routing exposing (parseAppLocation, parseLoginLocation)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( NotConnected route loginModel, msg ) ->
            updateLogin msg route loginModel

        ( Connexion route, msg ) ->
            updateConnexion msg route

        ( Connected route session appModel usersModel talksModel, msg ) ->
            updateApp msg route session appModel usersModel talksModel


updateConnexion : Msg -> AppRoutes -> ( Model, Cmd Msg )
updateConnexion msg route =
    case msg of
        SessionUserResponse token response ->
            case Debug.log "sessionUserResponse" response of
                Ok rep ->
                    case ( rep.status, rep.data ) of
                        ( True, Just u ) ->
                            let
                                session =
                                    Session u token

                                model =
                                    Connected route session initialAppModel initialUsersModel initialTalksModel

                                cmds =
                                    [ getTalks session.token, Navigation.newUrl ("/#/users/all") ] ++
                                      if u.localisation.lon == 0 && u.localisation.lat == 0 then
                                        [ getIpLocalisation ]
                                      else
                                        []
                            in
                            case u.status of
                                Activated ->
                                    ( model, Cmd.batch cmds )

                                ResetPassword ->
                                    ( Connected route session { initialAppModel | message = Just "Please reset your password", showResetPwdForm = True } initialUsersModel initialTalksModel, Cmd.batch <| Navigation.newUrl "/#/edit_password" :: cmds )

                                Incomplete ->
                                    ( Connected route session { initialAppModel | message = Just "Please complete your profile", showEditAccountForm = True } initialUsersModel initialTalksModel, Cmd.batch <| Navigation.newUrl "/#/edit_account" :: cmds )

                                NotActivated ->
                                    ( NotConnected LoginRoute { initialLoginModel | message = Just "Please activate your email" }, Navigation.newUrl "/#/login" )

                        _ ->
                            ( NotConnected LoginRoute initialLoginModel, Cmd.none )

                _ ->
                    ( NotConnected LoginRoute initialLoginModel, Cmd.none )

        SaveToken s ->
            case s of
                [ token ] ->
                    if token /= "" then
                        ( Connexion route, getSessionUser token )
                    else
                        ( NotConnected LoginRoute initialLoginModel, Navigation.newUrl "/#/login" )

                _ ->
                    ( NotConnected LoginRoute initialLoginModel, Navigation.newUrl "/#/login" )

        LoginResponse response ->
            case Debug.log "login" response of
                Success rep ->
                    case ( rep.status, rep.token, rep.user ) of
                        ( True, Just t, Just user ) ->
                            ( Connexion (UsersRoute "all")
                            , Cmd.batch [ getSessionUser t, storeToken [ t ] ]
                            )

                        _ ->
                            ( NotConnected LoginRoute initialLoginModel, Navigation.newUrl "/#/login" )

                _ ->
                    ( NotConnected LoginRoute initialLoginModel
                    , Navigation.newUrl "/#/login"
                    )

        _ ->
            ( NotConnected LoginRoute initialLoginModel, Cmd.none )
