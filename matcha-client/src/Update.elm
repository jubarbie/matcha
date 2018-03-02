module Update exposing (..)

import Commands exposing (..)
import Dom
import Dom.Scroll as Scroll
import FormUtils exposing (..)
import Json.Decode
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Notif.NotifDecoder exposing (..)
import Notif.NotifModel exposing (..)
import Ports exposing (..)
import RemoteData exposing (..)
import Routing exposing (parseAppLocation, parseLoginLocation)
import Talk.TalkCommands exposing (..)
import Talk.TalkModel exposing (..)
import Talk.TalkUtils exposing (..)
import Task
import Time
import User.UserCommands exposing (..)
import User.UserHelper exposing (..)
import User.UserModel exposing (..)
import User.UserUpdate exposing (..)
import Utils exposing (..)
import AppUpdate exposing (updateAppModel)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (model, msg) of
      (NotConnected route loginModel, msg) ->
        updateLoginModel msg route loginModel
      (Connexion route , msg) ->
        updateConnexionModel msg route
      (Connected route session appModel, msg) ->
        updateAppModel msg route session appModel

updateConnexionModel : Msg -> AppRoutes -> (Model, Cmd Msg)
updateConnexionModel msg route =
  case msg of
    SessionUserResponse token response ->
        case Debug.log "sessionUserResponse" response of
            Ok rep ->
                case ( rep.status == "success", rep.data ) of
                    ( True, Just u ) ->
                        let
                            session =
                                Session u token
                            model = Connected route session initialAppModel
                        in
                        case u.status of
                            Activated ->
                                case route of
                                    TalksRoute ->
                                        ( model, getTalks session.token )

                                    TalkRoute a ->
                                        ( model, getTalks session.token )

                                    UsersRoute a ->
                                        ( model, Cmd.batch [ sendLikeNotif session.token u.username, sendVisitNotif session.token u.username, getRelevantUsers a session.token ] )

                                    UserRoute a ->
                                        ( model, Cmd.batch [ sendLikeNotif session.token u.username, sendVisitNotif session.token u.username, getRelevantUsers a session.token ] )

                                    AccountRoute ->
                                        ( Connected route session { initialAppModel | map_state = Models.Loading }, Cmd.none )

                                    EditAccountRoute ->
                                        ( Connected route session { initialAppModel | editAccountForm = initEditAccountForm session.user }, Cmd.none )

                                    _ ->
                                        ( model, Cmd.none )

                            ResetPassword ->
                                ( Connected route session { initialAppModel | message = Just "Please reset your password" }, Navigation.newUrl "/#/edit_password" )

                            Incomplete ->
                                ( Connected route session { initialAppModel | message = Just "Please complete your profile" }, Navigation.newUrl "/#/account" )

                            NotActivated ->
                                ( NotConnected LoginRoute { initialLoginModel | message = Just "Please activate your email" }, Navigation.newUrl "/#/login" )

                    _ ->
                        ( NotConnected LoginRoute initialLoginModel, Cmd.none  )

            _ ->
                ( NotConnected LoginRoute initialLoginModel, Cmd.none )
    _ ->
        ( NotConnected LoginRoute initialLoginModel, Cmd.none )

updateLoginModel : Msg -> LoginRoutes -> LoginModel -> (Model, Cmd Msg)
updateLoginModel msg route loginModel =
  case msg of
    SaveToken session ->
        case session of
            [ user, token ] ->
                if token /= "" && user /= "" then
                    ( Connexion <| UsersRoute "all", getSessionUser user token )
                else
                    ( NotConnected route loginModel, Navigation.newUrl "/#/login" )

            _ ->
                ( NotConnected route loginModel, Navigation.newUrl "/#/login" )

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
                       ( Connected (UsersRoute "all") session { initialAppModel | message = msg }
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
