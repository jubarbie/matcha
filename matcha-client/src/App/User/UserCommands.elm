module App.User.UserCommands exposing (..)

import Api.ApiDecoder exposing (..)
import Api.ApiRequest exposing (..)
import App.AppModels exposing (..)
import App.User.UserDecoder exposing (..)
import App.User.UserModel exposing (..)
import Http
import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Json.Encode as JsonEnc exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import RemoteData exposing (..)
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

                "matchers" ->
                    "http://localhost:3001/api/users/matchers"

                _ ->
                    "http://localhost:3001/api/users/relevant_users"
    in
    apiGetRequest (Just usersDecoder) token url
        |> Http.send UsersResponse


searchUser : SearchModel -> String -> Cmd Msg
searchUser search token =
    let
        url =
            "http://localhost:3001/api/users/search"

        minYear =
            case search.yearMin of
                Just y ->
                    2018 - y

                _ ->
                    2018

        maxYear =
            case search.yearMax of
                Just y ->
                    2018 - y

                _ ->
                    0

        maxDist =
            case search.loc of
                Just l ->
                    JsonEnc.int l

                _ ->
                    JsonEnc.bool False

        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "searchLogin", JsonEnc.string search.login )
                    , ( "searchTags", JsonEnc.list <| List.map JsonEnc.string search.tags )
                    , ( "searchMax", JsonEnc.int minYear )
                    , ( "searchMin", JsonEnc.int maxYear )
                    , ( "searchLoc", maxDist )
                    ]
    in
    apiPostRequest (Just usersDecoder) token url body
        |> Http.send SearchResponse


getUser : String -> String -> Cmd Msg
getUser user token =
    let
        url =
            "http://localhost:3001/api/users/user/" ++ user
    in
    apiGetRequest (Just decodeUser) token url
        |> Http.send UserResponse


getSessionUser : String -> Cmd Msg
getSessionUser token =
    let
        url =
            "http://localhost:3001/api/users/connected_user"
    in
    apiGetRequest (Just decodeSessionUser) token url
        |> Http.send (SessionUserResponse token)


updateAccountInfos : String -> String -> String -> String -> String -> Cmd Msg
updateAccountInfos fname lname email bio token =
    let
        url =
            "http://localhost:3001/api/users/update"

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
        url =
            "http://localhost:3001/api/users/toggle_like"

        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "username", JsonEnc.string username ) ]
    in
    apiPostRequest (Just decodeUser) token url body
        |> Http.send (LikeResponse username)


reportUser : String -> String -> Cmd Msg
reportUser user token =
    let
        url =
            "http://localhost:3001/api/users/report/" ++ user
    in
    apiGetRequest Nothing token url
        |> Http.send NoDataApiResponse


blockUser : String -> String -> Cmd Msg
blockUser user token =
    let
        url =
            "http://localhost:3001/api/users/block/" ++ user
    in
    apiGetRequest Nothing token url
        |> Http.send NoDataApiResponse


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

sendUnlikeNotif : String -> String -> Cmd Msg
sendUnlikeNotif token to =
    let
        body =
            JsonEnc.encode 0 <|
                JsonEnc.object
                    [ ( "jwt", JsonEnc.string token )
                    , ( "action", JsonEnc.string "unlike" )
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
    WebSocket.send "ws://localhost:3001/ws" body


getIpLocalisation : Cmd Msg
getIpLocalisation =
    Http.get "http://ip-api.com/json" decodeLocalisationResponse
        |> RemoteData.sendRequest
        |> Cmd.map GetIpLocalisationResponse


saveLocation : Localisation -> String -> Cmd Msg
saveLocation loc token =
    let
        url =
            "http://localhost:3001/api/users/save_loc"

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
        url =
            "http://localhost:3001/api/users/change_password"

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


updateGender : Gender -> String -> Cmd Msg
updateGender gender token =
    let
        url =
            "http://localhost:3001/api/users/update_gender"

        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "gender", JsonEnc.string <| genderToString <| Just gender ) ]
    in
    apiPostRequest (Just decodeSessionUser) token url body
        |> Http.send UpdateFieldResponse


updateIntIn : List Gender -> String -> Cmd Msg
updateIntIn genders token =
    let
        url =
            "http://localhost:3001/api/users/update_int_in"

        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "genders", encodeIntIn genders ) ]
    in
    apiPostRequest (Just decodeSessionUser) token url body
        |> Http.send UpdateFieldResponse

updateDateOfBirth : Int -> String -> Cmd Msg
updateDateOfBirth date token =
    let
        url =
            "http://localhost:3001/api/users/update_dob"

        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "dob", JsonEnc.int date ) ]
    in
    apiPostRequest (Just decodeSessionUser) token url body
        |> Http.send UpdateFieldResponse


searchTag : String -> String -> Cmd Msg
searchTag token search =
    let
        url =
            "http://localhost:3001/api/tag/search"

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
        url =
            "http://localhost:3001/api/tag/add"

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
        url =
            "http://localhost:3001/api/tag/remove"

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
        url =
            "http://localhost:3001/api/users/new_image"

        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "img", JsonEnc.string img ) ]
    in
    apiPostRequest (Just decodeSessionUser) token url body
        |> Http.send UpdateFieldResponse


delImg : Int -> String -> Cmd Msg
delImg id_ token =
    let
        url =
            "http://localhost:3001/api/users/del_image"

        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "id_img", JsonEnc.int id_ ) ]
    in
    apiPostRequest (Just decodeSessionUser) token url body
        |> Http.send UpdateFieldResponse

mainImg : Int -> String -> Cmd Msg
mainImg id_ token =
    let
        url =
            "http://localhost:3001/api/users/update_main_image"

        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "id_img", JsonEnc.int id_ ) ]
    in
    apiPostRequest (Just decodeSessionUser) token url body
        |> Http.send UpdateFieldResponse


logout : String -> Cmd Msg
logout token =
    let
        url =
            "http://localhost:3001/api/users/disconnect"
    in
    apiGetRequest Nothing token url
        |> Http.send NoDataApiResponse
