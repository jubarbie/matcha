module Update exposing (..)

import Login.LoginCommands exposing (..)
import FormUtils exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Ports exposing (..)
import RemoteData exposing (..)
import Routing exposing (parseAppLocation, parseLoginLocation)
import App.Talk.TalkCommands exposing (..)
import App.User.UserCommands exposing (..)
import App.User.UserModel exposing (..)
import App.AppUpdate exposing (updateAppModel)
import Login.LoginUpdate exposing (updateLoginModel)
import Login.LoginModels exposing (..)
import App.AppModels exposing (..)
import App.Talk.TalkModel exposing (..)
import App.User.UserModel exposing (..)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (model, msg) of
      (NotConnected route loginModel, msg) ->
        updateLoginModel msg route loginModel
      (Connexion route , msg) ->
        updateConnexionModel msg route
      (Connected route session appModel usersModel talksModel, msg) ->
        updateAppModel msg route session appModel usersModel talksModel

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
                            model = Connected route session initialAppModel initialUsersModel initialTalksModel
                            cmds = [ getTalks session.token ]
                        in
                        case u.status of
                            Activated ->
                                case route of

                                    UsersRoute a ->
                                        ( model, Cmd.batch <| cmds ++ [ sendLikeNotif session.token u.username, sendVisitNotif session.token u.username, getRelevantUsers a session.token ] )

                                    UserRoute a ->
                                        ( model, Cmd.batch <| cmds ++[ sendLikeNotif session.token u.username, sendVisitNotif session.token u.username, getRelevantUsers a session.token ] )

                                    AccountRoute ->
                                        ( Connected route session { initialAppModel | map_state = App.AppModels.Loading } initialUsersModel initialTalksModel, Cmd.batch <| cmds )

                                    EditAccountRoute ->
                                        ( Connected route session { initialAppModel | editAccountForm = initEditAccountForm session.user } initialUsersModel initialTalksModel, Cmd.batch <| cmds )

                                    _ ->
                                        ( model, Cmd.none )

                            ResetPassword ->
                                ( Connected route session { initialAppModel | message = Just "Please reset your password" } initialUsersModel initialTalksModel, Cmd.batch <| Navigation.newUrl "/#/edit_password" :: cmds )

                            Incomplete ->
                                ( Connected route session { initialAppModel | message = Just "Please complete your profile" } initialUsersModel initialTalksModel, Cmd.batch <| Navigation.newUrl "/#/account" :: cmds )

                            NotActivated ->
                                ( NotConnected LoginRoute { initialLoginModel | message = Just "Please activate your email" }, Navigation.newUrl "/#/login" )

                    _ ->
                        ( NotConnected LoginRoute initialLoginModel, Cmd.none  )

            _ ->
                ( NotConnected LoginRoute initialLoginModel, Cmd.none )

    SaveToken s ->
      case Debug.log "session" s of
          [ user, token ] ->
              if token /= "" && user /= "" then
                  ( Connexion route, getSessionUser user token  )
              else
                  ( NotConnected LoginRoute initialLoginModel, Navigation.newUrl "/#/login" )

          _ ->
              ( NotConnected LoginRoute initialLoginModel, Navigation.newUrl "/#/login" )

    _ ->
        ( NotConnected LoginRoute initialLoginModel, Cmd.none )
