module App.Admin.AdminCommands exposing (..)

import Api.ApiDecoder exposing (..)
import Api.ApiRequest exposing (..)
import App.AppModels exposing (..)
import App.Admin.AdminDecoder exposing (..)
import App.User.UserModel exposing (..)
import Http
import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Json.Encode as JsonEnc exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import RemoteData exposing (..)


fetchAdminUsers : String -> Int -> Cmd Msg
fetchAdminUsers token page =
    let
        url =
            "http://localhost:3001/api/admin/users"
    in
    apiGetRequest (Just decodeAdminUsers) token url
        |> Http.send AdminUsersResponse

deleteUser : String -> String -> Cmd Msg
deleteUser token username =
  let
      url =
          "http://localhost:3001/api/admin/delete/" ++ username
  in
  apiGetRequest Nothing token url
      |> Http.send NoDataApiResponse

fetchReportedUsers : String -> Cmd Msg
fetchReportedUsers token =
    let
        url =
            "http://localhost:3001/api/admin/reported_users"
    in
    apiGetRequest (Just decodeAdminUsers) token url
        |> Http.send AdminUsersResponse
