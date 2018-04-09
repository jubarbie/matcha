module Login.LoginUpdate exposing (..)

import App.AppModels exposing (..)
import App.User.UserModel exposing (..)
import FormUtils exposing (..)
import Login.LoginCommands exposing (..)
import Login.LoginModels exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Ports exposing (..)
import RemoteData exposing (..)
import Routing exposing (parseAppLocation, parseLoginLocation)


updateLogin : Msg -> LoginRoutes -> LoginModel -> ( Model, Cmd Msg )
updateLogin msg route loginModel =
    case msg of
        ResetPwdResponse response ->
            case response of
                Success rep ->
                    if rep.status == True then
                        ( NotConnected route { loginModel | message = Just "A email have been sent with your new password" }, Navigation.newUrl "/#/login" )
                    else
                        ( NotConnected route { loginModel | message = Just "Unknown user" }, Cmd.none )

                _ ->
                    ( initialModel LoginRoute, Cmd.none )

        NewUserResponse response ->
            case Debug.log "rep" response of
                Success rep ->
                    if rep.status then
                      ( NotConnected route { loginModel | message = Just "Your account has been created, check your emails" }
                      , Cmd.batch <|
                        [ Navigation.newUrl "/#/login"] ++
                          case rep.message of
                            Just m -> [ openNewTab m ]
                            _ -> []
                          )
                    else
                      ( NotConnected route { loginModel | message = rep.message, newUserForm = initFastNewUserForm }, Cmd.none )

                _ ->
                    ( initialModel LoginRoute, Cmd.none )

        UpdateLoginForm id_ value ->
            let
                form_ =
                    loginModel.loginForm

                newForm =
                    updateInput form_ id_ (Just value)
            in
            ( NotConnected route { loginModel | loginForm = newForm }, Cmd.none )

        UpdateResetPwdForm id_ value ->
            let
                form_ =
                    loginModel.resetPwdForm

                newForm =
                    updateInput form_ id_ (Just value)
            in
            ( NotConnected route { loginModel | resetPwdForm = newForm }, Cmd.none )

        UpdateNewUserForm id_ value ->
            let
                form_ =
                    loginModel.newUserForm

                newForm =
                    updateInput form_ id_ (Just value)
            in
            ( NotConnected route { loginModel | newUserForm = newForm }, Cmd.none )

        SendLogin ->
            let
                values =
                    List.map (\i -> i.status) loginModel.loginForm
            in
            case values of
                [ Valid a, Valid b ] ->
                    ( Connexion (UsersRoute "all"), sendLogin a b )

                _ ->
                    ( NotConnected route loginModel, Cmd.none )

        ResetPwd ->
            let
                values =
                    List.map (\i -> i.status) loginModel.resetPwdForm
            in
            case values of
                [ Valid a, Valid b ] ->
                    ( NotConnected route loginModel, resetPwd a b )

                _ ->
                    ( NotConnected route loginModel, Cmd.none )

        NewUser ->
            let
                values =
                    List.map (\i -> i.status) loginModel.newUserForm
            in
              case values of
                  [ Valid username, Valid fname, Valid lname, Valid email, Valid pwd, Valid repwd ] ->
                      ( NotConnected route loginModel, sendFastNewUser username fname lname email pwd repwd loginModel.localisation )

                  _ ->
                      ( NotConnected route loginModel, Cmd.none )

        OnLocationChange location ->
            let
                newRoute =
                    parseLoginLocation location
            in
            ( NotConnected newRoute loginModel, Cmd.none )

        _ ->
            ( NotConnected route loginModel, Cmd.none )
