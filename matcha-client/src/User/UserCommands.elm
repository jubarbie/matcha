module User.UserCommands exposing (..)

import Http
import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Json.Encode as JsonEnc exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import RemoteData exposing (..)
import User.UserModel exposing (..)
import WebSocket
import User.UserDecoder exposing (..)
import Api.ApiDecoder exposing (..)


getRelevantUsers : String -> String -> Cmd Msg
getRelevantUsers users token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token ) ]

        url =
            case users of
                "visitors" ->
                    "http://localhost:3001/api/users/visitors"

                "likers" ->
                    "http://localhost:3001/api/users/likers"

                _ ->
                    "http://localhost:3001/api/users/relevant_users"
    in
    Http.post url body (decodeApiResponse <| Just usersDecoder)
        |> RemoteData.sendRequest
        |> Cmd.map UsersResponse


getUser : String -> String -> Cmd Msg
getUser user token =
    let
        body =
            Http.jsonBody <| JsonEnc.object [ ( "token", JsonEnc.string token ) ]
    in
    Http.post ("http://localhost:3001/api/users/user/" ++ user) body (decodeApiResponse <| Just decodeUser)
        |> RemoteData.sendRequest
        |> Cmd.map UserResponse


getSessionUser : String -> String -> Cmd Msg
getSessionUser user token =
    let
        body =
            Http.jsonBody <| JsonEnc.object [ ( "token", JsonEnc.string token ) ]
    in
    Http.post "http://localhost:3001/api/users/connected_user" body (decodeApiResponse <| Just decodeSessionUser)
        |> RemoteData.sendRequest
        |> Cmd.map (SessionUserResponse token)


updateAccountInfos : String -> String -> String -> String -> String -> Cmd Msg
updateAccountInfos fname lname email bio token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "email", JsonEnc.string email )
                    , ( "fname", JsonEnc.string fname )
                    , ( "lname", JsonEnc.string lname )
                    , ( "bio", JsonEnc.string bio )
                    ]
    in
    Http.post "http://localhost:3001/api/users/update" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map (EditAccountResponse email fname lname bio)


toggleLike : String -> String -> Cmd Msg
toggleLike username token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "username", JsonEnc.string username )
                    , ( "token", JsonEnc.string token )
                    ]
    in
    Http.post "http://localhost:3001/api/users/toggle_like" body (decodeApiResponse <| Just decodeMatch)
        |> RemoteData.sendRequest
        |> Cmd.map (ToggleLikeResponse username)


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
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "lat", JsonEnc.float loc.lat )
                    , ( "lon", JsonEnc.float loc.lon )
                    ]
    in
    Http.post "http://localhost:3001/api/users/save_loc" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map SaveLocRespone


changePwd : String -> String -> String -> String -> Cmd Msg
changePwd oldPwd newPwd confirmNewPwd token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "oldPwd", JsonEnc.string oldPwd )
                    , ( "newPwd", JsonEnc.string newPwd )
                    , ( "reNewPwd", JsonEnc.string confirmNewPwd )
                    ]
    in
    Http.post "http://localhost:3001/api/users/change_password" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map ChangePwdRespone


updateField : Gender -> String -> Cmd Msg
updateField gender token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "gender", JsonEnc.string <| genderToString <| Just gender )
                    ]
    in
    Http.post "http://localhost:3001/api/users/update_gender" body (decodeApiResponse <| Just decodeSessionUser)
        |> RemoteData.sendRequest
        |> Cmd.map (UpdateFieldResponse token)


updateIntIn : List Gender -> String -> Cmd Msg
updateIntIn genders token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "genders", encodeIntIn genders )
                    ]
    in
    Http.post "http://localhost:3001/api/users/update_int_in" body (decodeApiResponse <| Just decodeSessionUser)
        |> RemoteData.sendRequest
        |> Cmd.map (UpdateFieldResponse token)


searchTag : String -> String -> Cmd Msg
searchTag token search =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "search", JsonEnc.string search )
                    ]
    in
    Http.post "http://localhost:3001/api/tag/search" body (decodeApiResponse <| Just (JsonDec.list JsonDec.string))
        |> RemoteData.sendRequest
        |> Cmd.map SearchTagResponse


addTag : String -> String -> Cmd Msg
addTag tag_ token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "tag", JsonEnc.string tag_ )
                    ]
    in
    Http.post "http://localhost:3001/api/tag/add" body (decodeApiResponse <| Just (JsonDec.list JsonDec.string))
        |> RemoteData.sendRequest
        |> Cmd.map ReqTagResponse


removeTag : String -> String -> Cmd Msg
removeTag tag_ token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "tag", JsonEnc.string tag_ )
                    ]
    in
    Http.post "http://localhost:3001/api/tag/remove" body (decodeApiResponse <| Just (JsonDec.list JsonDec.string))
        |> RemoteData.sendRequest
        |> Cmd.map ReqTagResponse


uploadImage : String -> String -> Cmd Msg
uploadImage img token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "img", JsonEnc.string img )
                    ]
    in
    Http.post "http://localhost:3001/api/users/new_image" body (decodeApiResponse <| Just decodeSessionUser)
        |> RemoteData.sendRequest
        |> Cmd.map (UpdateFieldResponse token)


delImg : Int -> String -> Cmd Msg
delImg id_ token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "id_img", JsonEnc.int id_ )
                    ]
    in
    Http.post "http://localhost:3001/api/users/del_image" body (decodeApiResponse <| Just decodeSessionUser)
        |> RemoteData.sendRequest
        |> Cmd.map (UpdateFieldResponse token)
