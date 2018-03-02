module Login.LoginUpdate exposing (..)

import Login.LoginCommands exposing (..)
import FormUtils exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Ports exposing (..)
import RemoteData exposing (..)
import Routing exposing (parseAppLocation, parseLoginLocation)
import App.User.UserModel exposing (..)
import Login.LoginModels exposing (..)
import App.AppUpdate exposing (updateAppModel)
import App.AppModels exposing (..)
import App.Talk.TalkModel exposing (..)


updateLoginModel : Msg -> LoginRoutes -> LoginModel -> (Model, Cmd Msg)
updateLoginModel msg route loginModel =
  case msg of

    LoginResponse response ->
       case Debug.log "login response" response of
           Success rep ->
               case ( rep.status == "success", rep.token, rep.user ) of
                   ( True, Just t, Just user ) ->
                       let
                           session = Session user t

                           ( route, msg ) =
                               case user.status of
                                   ResetPassword ->
                                       ( "/#/edit_password", Just "Please reset your password" )

                                   _ ->
                                       ( "/#/users", Nothing )
                       in
                       ( Connected (UsersRoute "all") session { initialAppModel | message = msg } initialUsersModel initialTalksModel
                       , Cmd.batch [ Navigation.newUrl route, storeToken [ user.username, t ] ]
                       )

                   _ ->
                       ( NotConnected LoginRoute initialLoginModel, Navigation.newUrl "/#/login" )

           _ ->
               ( NotConnected LoginRoute initialLoginModel
               , Navigation.newUrl "/#/login"
               )

    ResetPwdResponse response ->
        case response of
            Success rep ->
                if rep.status == "success" then
                    ( NotConnected route { loginModel | message = Just "A email have been sent with your new password" }, Navigation.newUrl "/#/login" )
                else
                    ( NotConnected route { loginModel | message = Just "Unknown user" }, Cmd.none )

            _ ->
                ( initialModel LoginRoute, Cmd.none )

    NewUserResponse response ->
        case response of
            Success rep ->
                case rep.status of
                    "success" ->
                        ( NotConnected route  { loginModel | message = Just "Your account has been created, check your emails" }, Navigation.newUrl "/#/login" )

                    _ ->
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
                ( NotConnected route loginModel, sendLogin a b )

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
                ( NotConnected route loginModel, sendFastNewUser username fname lname email pwd repwd )

            _ ->
                ( NotConnected route loginModel, Cmd.none )

    _ -> ( NotConnected route loginModel, Cmd.none )