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
            case response of
                Ok rep ->
                    case ( rep.status, rep.data ) of
                        ( True, Just u ) ->
                            let
                                session =
                                    Session u token

                                model =
                                    Connected route session initialAppModel initialUsersModel initialTalksModel

                                cmds =
                                    [ getTalks session.token, sendLikeNotif token u.username, sendUnlikeNotif token u.username, sendVisitNotif token u.username, Navigation.newUrl "/#/users/all" ]
                                        ++ (if u.localisation.lon == 0 && u.localisation.lat == 0 then
                                                [ tryToLocalize () ]
                                            else
                                                []
                                           )
                            in
                            case u.status of
                                Activated ->
                                    ( model, Cmd.batch cmds )

                                ResetPassword ->
                                    ( Connected route session { initialAppModel | message = Just "Please reset your password", showResetPwdForm = True, showAccountMenu = True } initialUsersModel initialTalksModel, Cmd.batch cmds )

                                Incomplete ->
                                    ( Connected route session { initialAppModel | message = Just "Please complete your profile", showEditAccountForm = True, showAccountMenu = True } initialUsersModel initialTalksModel, Cmd.batch cmds )

                                NotActivated ->
                                    ( NotConnected LoginRoute { initialLoginModel | message = Just "Please activate your email" }, Cmd.none )

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
            case response of
                Success rep ->
                    case ( rep.status, rep.token, rep.user, rep.message ) of
                        ( True, Just t, Just user, _ ) ->
                            ( Connexion (UsersRoute "all")
                            , Cmd.batch [ getSessionUser t, storeToken [ t ] ]
                            )

                        ( _, _, _, msg ) ->
                            ( NotConnected LoginRoute { initialLoginModel | message = msg }, Cmd.none )

                _ ->
                    ( NotConnected LoginRoute { initialLoginModel | message = Just "Error" }
                    , Cmd.none
                    )

        _ ->
            ( NotConnected LoginRoute initialLoginModel, Cmd.none )
