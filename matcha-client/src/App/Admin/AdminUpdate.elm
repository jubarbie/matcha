module App.Admin.AdminUpdate exposing (..)

import App.Admin.AdminModel exposing (..)
import Msgs exposing (..)
import App.AppModels exposing (..)
import Http
import Models exposing (..)
import Navigation
import Login.LoginModels exposing (..)
import App.Talk.TalkModel exposing (..)
import App.User.UserModel exposing (..)
import App.Admin.AdminCommands exposing (..)


updateAdmin : Msg -> Session -> AdminModel -> ( Model, Cmd Msg )
updateAdmin msg session adminModel =
    let
        model =
            Admin session adminModel
    in
    case msg of
        NoOp ->
            ( model, Cmd.none )

        AdminUsersResponse response ->
          case response of
              Ok rep ->
                  case ( rep.status, rep.data ) of
                      ( True, Just users ) ->
                          ( Admin session { adminModel | users = updateUsers adminModel.users users, fetching = False }, Cmd.none )

                      _ ->
                          ( Admin session { adminModel | fetching = False }, Cmd.none )

              Err err ->
                  handleAdminErrorRequest err model session Cmd.none

        NextPage ->
          (Admin session {adminModel | page = adminModel.page + 1, fetching = True }, fetchAdminUsers session.token (adminModel.page + 1))

        ReportedUsers ->
          (Admin session { adminModel | fetching = True, users = Reported [] }, fetchReportedUsers session.token)

        AllUsers ->
          (Admin session { adminModel | fetching = True, users = All [], page = 1 }, fetchAdminUsers session.token 1)

        DeleteUser username  ->
          (Admin session adminModel, deleteUser session.token username)

        _ ->
          ( Admin session { adminModel | fetching = False }, Cmd.none )

updateUsers : AdminUsers -> List SessionUser -> AdminUsers
updateUsers m u =
  case m of
    All a -> All u
    Reported a -> Reported u

handleAdminErrorRequest : Http.Error -> Model -> Session -> Cmd Msg -> ( Model, Cmd Msg )
handleAdminErrorRequest err model session cmd =
    case err of
        Http.BadStatus s ->
            if s.status.code == 401 then
                ( Connected (UsersRoute "all") session initialAppModel initialUsersModel initialTalksModel , Navigation.newUrl "/#/users/all" )
            else
                ( initialModel LoginRoute, Navigation.newUrl "/#/login" )

        _ ->
            ( initialModel LoginRoute, Navigation.newUrl "/#/login" )
