module User.UserCommands exposing (..)

import Api.ApiDecoder exposing (..)
import Http
import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Json.Encode as JsonEnc exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import RemoteData exposing (..)
import User.UserDecoder exposing (..)
import User.UserModel exposing (..)
import Api.ApiRequest exposing (..)
import WebSocket


getRelevantUsers : String -> String -> Cmd Msg
getRelevantUsers users token =
    let
        url =
            case users of
                "visitors" ->
                    "http://localhost:3001/api/users/visitors"

                "likers" ->
                    "http://localhost:3001/api/users/likers"

                _ ->
                    "http://localhost:3001/api/users/relevant_users"
    in
      apiGetRequest (Just usersDecoder) token url
      |> Http.send UsersResponse

getUser : String -> String -> Cmd Msg
getUser user token =
  let
    url = "http://localhost:3001/api/users/user/" ++ user
  in
    apiGetRequest (Just decodeUser) token url
    |> Http.send UserResponse


getSessionUser : String -> String -> Cmd Msg
getSessionUser user token =
    let
        url = "http://localhost:3001/api/users/connected_user"
    in
      apiGetRequest (Just decodeSessionUser) token url
      |> Http.send (SessionUserResponse token)


updateAccountInfos : String -> String -> String -> String -> String -> Cmd Msg
updateAccountInfos fname lname email bio token =
    let
        url = "http://localhost:3001/api/users/update"
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "email", JsonEnc.string email )
                    , ( "fname", JsonEnc.string fname )
                    , ( "lname", JsonEnc.string lname )
                    , ( "bio", JsonEnc.string bio )
                    ]
    in
      apiPostRequest Nothing token url body
      |> Http.send (EditAccountResponse email fname lname bio)


toggleLike : String -> String -> Cmd Msg
toggleLike username token =
    let
      url = "http://localhost:3001/api/users/toggle_like"
      body =
          Http.jsonBody <|
              JsonEnc.object
                  [ ( "username", JsonEnc.string username ) ]
    in
      apiPostRequest (Just decodeMatch) token url body
      |> Http.send (ToggleLikeResponse username)


sendLikeNotif : String -> String -> Cmd Msg
sendLikeNotif token to =
    let
        body =
            JsonEnc.encode 0 <|
                JsonEnc.object
                    [ ( "jwt", JsonEnc.string token )
                    , ( "action", JsonEnc.string "like" )
                    , ( "to", JsonEnc.string to )
                    ]
    in
      WebSocket.send "ws://localhost:3001/ws" body


sendVisitNotif : String -> String -> Cmd Msg
sendVisitNotif token to =
    let
        body =
            JsonEnc.encode 0 <|
                JsonEnc.object
                    [ ( "jwt", JsonEnc.string token )
                    , ( "action", JsonEnc.string "visit" )
                    , ( "to", JsonEnc.string to )
                    ]
    in
      WebSocket.send "ws://localhost:3001/ws" <| Debug.log "notif" body


getIpLocalisation : Cmd Msg
getIpLocalisation =
    Http.get "http://ip-api.com/json" decodeLocalisationResponse
        |> RemoteData.sendRequest
        |> Cmd.map GetIpLocalisation


saveLocation : Localisation -> String -> Cmd Msg
saveLocation loc token =
    let
        url = "http://localhost:3001/api/users/save_loc"
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "lat", JsonEnc.float loc.lat )
                    , ( "lon", JsonEnc.float loc.lon )
                    ]
    in
      apiPostRequest Nothing token url body
      |> Http.send SaveLocRespone


changePwd : String -> String -> String -> String -> Cmd Msg
changePwd oldPwd newPwd confirmNewPwd token =
    let
        url = "http://localhost:3001/api/users/change_password"
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "oldPwd", JsonEnc.string oldPwd )
                    , ( "newPwd", JsonEnc.string newPwd )
                    , ( "reNewPwd", JsonEnc.string confirmNewPwd )
                    ]
    in
      apiPostRequest Nothing token url body
      |> Http.send ChangePwdRespone


updateField : Gender -> String -> Cmd Msg
updateField gender token =
    let
        url = "http://localhost:3001/api/users/update_gender"
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "gender", JsonEnc.string <| genderToString <| Just gender ) ]
    in
      apiPostRequest (Just decodeSessionUser) token url body
      |> Http.send (UpdateFieldResponse token)


updateIntIn : List Gender -> String -> Cmd Msg
updateIntIn genders token =
    let
        url = "http://localhost:3001/api/users/update_int_in"
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "genders", encodeIntIn genders ) ]
    in
      apiPostRequest (Just decodeSessionUser) token url body
      |> Http.send (UpdateFieldResponse token)


searchTag : String -> String -> Cmd Msg
searchTag token search =
    let
        url = "http://localhost:3001/api/tag/search"
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "search", JsonEnc.string search ) ]
    in
      apiPostRequest (Just (JsonDec.list JsonDec.string)) token url body
      |> Http.send SearchTagResponse


addTag : String -> String -> Cmd Msg
addTag tag_ token =
    let
        url = "http://localhost:3001/api/tag/add"
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "tag", JsonEnc.string tag_ ) ]
    in
      apiPostRequest (Just (JsonDec.list JsonDec.string)) token url body
      |> Http.send ReqTagResponse


removeTag : String -> String -> Cmd Msg
removeTag tag_ token =
    let
        url = "http://localhost:3001/api/tag/remove"
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "tag", JsonEnc.string tag_ ) ]
    in
      apiPostRequest (Just (JsonDec.list JsonDec.string)) token url body
      |> Http.send ReqTagResponse



uploadImage : String -> String -> Cmd Msg
uploadImage img token =
    let
        url = "http://localhost:3001/api/users/new_image"
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "img", JsonEnc.string img ) ]
    in
       apiPostRequest (Just decodeSessionUser) token url body
       |> Http.send (UpdateFieldResponse token)


delImg : Int -> String -> Cmd Msg
delImg id_ token =
    let
        url = "http://localhost:3001/api/users/del_image"
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "id_img", JsonEnc.int id_ ) ]
    in
      apiPostRequest (Just decodeSessionUser) token url body
      |> Http.send (UpdateFieldResponse token)
