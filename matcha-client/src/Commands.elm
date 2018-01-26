module Commands exposing (..)

import Http
import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Json.Encode as JsonEnc exposing (..)
import RemoteData exposing (..)
import Models exposing (..)
import UserModel exposing (..)
import Msgs exposing (..)
import WebSocket

decodeLocalisationResponse : Decoder LocalisationApi
decodeLocalisationResponse =
  JsonDec.map3 LocalisationApi
  (at ["status"] JsonDec.string)
  (maybe (at ["lon"] JsonDec.float))
  (maybe (at ["lat"] JsonDec.float))

encodeIntIn : List Gender -> JsonEnc.Value
encodeIntIn intIn =
  JsonEnc.list (List.map (\g -> JsonEnc.string <| genderToString <| Just g) intIn)

usersDecoder : Decoder (List User)
usersDecoder =
    JsonDec.list decodeUser

notificationDecoder : Decoder Notif
notificationDecoder =
    JsonDec.succeed Notif
      |: (field "message" notifTypeDecoder)
      |: (field "to" JsonDec.string)
      |: (field "from" JsonDec.string)

notifTypeDecoder : Decoder NotificationType
notifTypeDecoder =
    JsonDec.string |> JsonDec.andThen
        (\a -> case a of
            "message" -> JsonDec.succeed NotifMessage
            "visit" -> JsonDec.succeed NotifVisit
            "like" -> JsonDec.succeed NotifLike
            _ -> JsonDec.fail "Notif unknown"
        )

usersSessionDecoder : Decoder (List SessionUser)
usersSessionDecoder =
    JsonDec.list decodeSessionUser

decodeIntIn : Decoder (List Gender)
decodeIntIn =
    JsonDec.list decodeGender

decodeGender : Decoder Gender
decodeGender =
    JsonDec.string |> JsonDec.andThen
        (\a -> case a of
            "M" -> JsonDec.succeed M
            "F" -> JsonDec.succeed F
            _ -> JsonDec.fail "Gender must be M or F"
        )

decodeMatch : Decoder MatchStatus
decodeMatch =
    JsonDec.string |> JsonDec.andThen
        (\a -> case a of
            "none" -> JsonDec.succeed None
            "from" -> JsonDec.succeed From
            "to" -> JsonDec.succeed To
            "match" -> JsonDec.succeed Match
            _ -> JsonDec.fail "Gender must be M or F"
        )

decodeRole : Decoder UserRole
decodeRole =
    JsonDec.int |> JsonDec.andThen
        (\a -> case a of
            0 -> JsonDec.succeed ADMIN
            1 -> JsonDec.succeed USER
            _ -> JsonDec.fail "Unknown role"
        )

decodeUserStatus : Decoder UserStatus
decodeUserStatus =
    JsonDec.string |> JsonDec.andThen
        (\a -> case a of
            "activated" -> JsonDec.succeed Activated
            "resetpwd" -> JsonDec.succeed ResetPassword
            "incomplete" -> JsonDec.succeed Incomplete
            _ -> JsonDec.succeed NotActivated
        )

decodeTalks : Decoder (List String)
decodeTalks =
  JsonDec.list decodeTalkUsername

decodeTalkUsername : Decoder String
decodeTalkUsername =
  JsonDec.string

talkDecoder : Decoder (List Message)
talkDecoder =
    JsonDec.list decodeMessage

decodeMessage : Decoder Message
decodeMessage =
  JsonDec.succeed Message
    |: (field "date" JsonDec.string)
    |: (field "message" JsonDec.string)
    |: (field "username" JsonDec.string)

decodeLocalisation : Decoder Localisation
decodeLocalisation =
  JsonDec.succeed Localisation
    |: (field "lon" JsonDec.float)
    |: (field "lat" JsonDec.float)

decodeSessionUser : Decoder SessionUser
decodeSessionUser =
  JsonDec.succeed SessionUser
    |: (field "login" JsonDec.string)
    |: (field "fname" JsonDec.string)
    |: (field "lname" JsonDec.string)
    |: (field "email" JsonDec.string)
    |: maybe (field "gender" decodeGender)
    |: (field "interested_in" decodeIntIn)
    |: (field "bio" JsonDec.string)
    |: (field "talks" decodeTalks)
    |: (field "tags" (JsonDec.list JsonDec.string))
    |: maybe (field "localisation" decodeLocalisation)
    |: (field "photos" decodeImgs)
    |: (field "rights" decodeRole)
    |: (field "activated" decodeUserStatus)

arrayAsTuple2 : Decoder a -> Decoder b -> Decoder (a, b)
arrayAsTuple2 a b =
    index 0 a
        |> JsonDec.andThen (\aVal -> index 1 b
        |> JsonDec.andThen (\bVal -> JsonDec.succeed (aVal, bVal)))

decodeImgs : Decoder (List (Int, String))
decodeImgs =
  JsonDec.list <| arrayAsTuple2 JsonDec.int JsonDec.string

decodeUser : Decoder User
decodeUser =
  JsonDec.succeed User
    |: (field "login" JsonDec.string)
    |: maybe (field "gender" decodeGender)
    |: (field "bio" JsonDec.string)
    |: (field "match" decodeMatch)
    |: (field "has_talk" JsonDec.bool)
    |: (field "visitor" JsonDec.bool)
    |: (field "tags" (JsonDec.list JsonDec.string))
    |: (field "photos" (JsonDec.list JsonDec.string))
    |: (field "last_connection" JsonDec.string)
    |: maybe (field "distance" JsonDec.float)


decodeApiResponse : Maybe (Decoder a) -> Decoder (ApiResponse (Maybe a))
decodeApiResponse decoder =
    case decoder of
        Just d ->
            JsonDec.map3 ApiResponse
            (at ["status"] JsonDec.string)
            (maybe (at ["msg"] JsonDec.string))
            (maybe (at ["data"] d))
        _ ->
            JsonDec.map3 ApiResponse
            (at ["status"] JsonDec.string)
            (maybe (at ["msg"] JsonDec.string))
            (JsonDec.succeed Nothing)

decodeAuthResponse : Decoder AuthResponse
decodeAuthResponse =
    JsonDec.map4 AuthResponse
    (at ["status"] JsonDec.string)
    (maybe (at ["msg"] JsonDec.string))
    (maybe (at ["token"] JsonDec.string))
    (maybe (at ["data"] decodeSessionUser))

getUsers : String -> Cmd Msg
getUsers token  =
    let
        body =
            Http.jsonBody <| JsonEnc.object [("token", JsonEnc.string token)]
    in
        Http.post "http://localhost:3001/api/admin/all_users" body (decodeApiResponse <| Just usersSessionDecoder)
        |> RemoteData.sendRequest
        |> Cmd.map UsersAdminResponse

getRelevantUsers : String -> Cmd Msg
getRelevantUsers token  =
    let
        body =
            Http.jsonBody <| JsonEnc.object [("token", JsonEnc.string token)]
    in
        Http.post "http://localhost:3001/api/users/relevant_users" body (decodeApiResponse <| Just usersDecoder)
        |> RemoteData.sendRequest
        |> Cmd.map UsersResponse

getUser : String -> String -> Cmd Msg
getUser user token  =
    let
        body =
            Http.jsonBody <| JsonEnc.object [("token", JsonEnc.string token)]
    in
        Http.post ("http://localhost:3001/api/users/user/" ++ user) body (decodeApiResponse <| Just decodeUser)
        |> RemoteData.sendRequest
        |> Cmd.map UserResponse

getSessionUser : String -> String -> Cmd Msg
getSessionUser user token  =
    let
        body =
            Http.jsonBody <| JsonEnc.object [("token", JsonEnc.string token)]
    in
        Http.post ("http://localhost:3001/api/users/connected_user") body (decodeApiResponse <| Just decodeSessionUser)
        |> RemoteData.sendRequest
        |> Cmd.map (SessionUserResponse token)

sendLogin : String -> String -> Cmd Msg
sendLogin login pwd =
    let
        body =
            Http.jsonBody <| JsonEnc.object [("login", JsonEnc.string login), ("password", JsonEnc.string pwd)]
    in
        Http.post "http://localhost:3001/auth" body decodeAuthResponse
        |> RemoteData.sendRequest
        |> Cmd.map LoginResponse

resetPwd : String -> String -> Cmd Msg
resetPwd login email =
    let
        body =
            Http.jsonBody <| JsonEnc.object [("username", JsonEnc.string login), ("email", JsonEnc.string email)]
    in
        Http.post "http://localhost:3001/auth/reset_password" body (decodeApiResponse <| Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map ResetPwdResponse

sendFastNewUser : String -> String -> String -> String -> String -> String -> Cmd Msg
sendFastNewUser username fname lname email pwd repwd =
    let
        body =
            Http.jsonBody <| JsonEnc.object
            [ ("username", JsonEnc.string username)
            , ("fname", JsonEnc.string fname)
            , ("lname", JsonEnc.string lname)
            , ("email", JsonEnc.string email)
            , ("password", JsonEnc.string pwd)
            , ("rePassword", JsonEnc.string repwd)
            ]
    in
        Http.post "http://localhost:3001/auth/newfast" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map NewUserResponse


updateAccountInfos : String -> String -> String -> String -> String -> Cmd Msg
updateAccountInfos fname lname email bio token =
    let
        body =
            Http.jsonBody <| JsonEnc.object
            [ ("token", JsonEnc.string token)
            , ("email", JsonEnc.string email)
            , ("fname", JsonEnc.string fname)
            , ("lname", JsonEnc.string lname)
            , ("bio", JsonEnc.string bio)
            ]
    in
        Http.post "http://localhost:3001/api/users/update" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map (EditAccountResponse email fname lname bio)

deleteUser : String -> String -> Cmd Msg
deleteUser username token =
    let
        body =
            Http.jsonBody <| JsonEnc.object
            [ ("username", JsonEnc.string username)
            , ("token", JsonEnc.string token)
            ]
    in
        Http.post "http://localhost:3001/api/admin/delete_user" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map (DeleteUserResponse username)

toggleLike : String -> String -> Cmd Msg
toggleLike username token =
    let
        body =
            Http.jsonBody <| JsonEnc.object
            [ ("username", JsonEnc.string username)
            , ("token", JsonEnc.string token)
            ]
    in
        Http.post "http://localhost:3001/api/users/toggle_like" body (decodeApiResponse <| Just decodeMatch)
        |> RemoteData.sendRequest
        |> Cmd.map (ToggleLikeResponse username)

getTalk : String -> String -> Cmd Msg
getTalk username token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token) ]
  in
      Http.post ("http://localhost:3001/api/talks/talk/" ++ username) body (decodeApiResponse <| Just talkDecoder )
      |> RemoteData.sendRequest
      |> Cmd.map GetTalkResponse

getTalks : String -> Cmd Msg
getTalks token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token) ]
  in
      Http.post "http://localhost:3001/api/talks/all_talks/" body (decodeApiResponse <| Just decodeTalks )
      |> RemoteData.sendRequest
      |> Cmd.map GetTalksResponse

sendMessage : String -> String -> String -> Cmd Msg
sendMessage token to message =
  let
      body =
          JsonEnc.encode 0 <| JsonEnc.object
          [ ("jwt", JsonEnc.string token)
          , ("action", JsonEnc.string "new_message")
          , ("to", JsonEnc.string to)
          , ("message", JsonEnc.string message)
          ]
  in
      WebSocket.send "ws://localhost:3001/ws" body

getIpLocalisation : Cmd Msg
getIpLocalisation =
    Http.get "http://ip-api.com/json" decodeLocalisationResponse
    |> RemoteData.sendRequest
    |> Cmd.map GetIpLocalisation

saveLocation : Localisation -> String -> Cmd Msg
saveLocation loc token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token)
          , ("lat", JsonEnc.float loc.lat)
          , ("lon", JsonEnc.float loc.lon)
          ]
  in
      Http.post "http://localhost:3001/api/users/save_loc" body (decodeApiResponse Nothing)
      |> RemoteData.sendRequest
      |> Cmd.map SaveLocRespone

changePwd : String -> String -> String -> String -> Cmd Msg
changePwd oldPwd newPwd confirmNewPwd token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token)
          , ("oldPwd", JsonEnc.string oldPwd)
          , ("newPwd", JsonEnc.string newPwd)
          , ("reNewPwd", JsonEnc.string confirmNewPwd)
          ]
  in
      Http.post "http://localhost:3001/api/users/change_password" body (decodeApiResponse Nothing)
      |> RemoteData.sendRequest
      |> Cmd.map ChangePwdRespone

updateField : Gender -> String -> Cmd Msg
updateField gender token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token)
          , ("gender", JsonEnc.string <| genderToString <| Just gender)
          ]
  in
      Http.post "http://localhost:3001/api/users/update_gender" body (decodeApiResponse <| Just decodeSessionUser)
      |> RemoteData.sendRequest
      |> Cmd.map (UpdateFieldResponse token)

updateIntIn : List Gender -> String -> Cmd Msg
updateIntIn genders token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token)
          , ("genders", encodeIntIn genders)
          ]
  in
      Http.post "http://localhost:3001/api/users/update_int_in" body (decodeApiResponse <| Just decodeSessionUser)
      |> RemoteData.sendRequest
      |> Cmd.map (UpdateFieldResponse token)

searchTag : String -> String -> Cmd Msg
searchTag token search =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token)
          , ("search", JsonEnc.string search)
          ]
  in
      Http.post "http://localhost:3001/api/tag/search" body (decodeApiResponse <| Just (JsonDec.list JsonDec.string))
      |> RemoteData.sendRequest
      |> Cmd.map SearchTagResponse

addTag : String -> String -> Cmd Msg
addTag tag_ token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token)
          , ("tag", JsonEnc.string tag_)
          ]
  in
      Http.post "http://localhost:3001/api/tag/add" body (decodeApiResponse <| Just (JsonDec.list JsonDec.string))
      |> RemoteData.sendRequest
      |> Cmd.map ReqTagResponse

removeTag : String -> String -> Cmd Msg
removeTag tag_ token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token)
          , ("tag", JsonEnc.string tag_)
          ]
  in
      Http.post "http://localhost:3001/api/tag/remove" body (decodeApiResponse <| Just (JsonDec.list JsonDec.string))
      |> RemoteData.sendRequest
      |> Cmd.map ReqTagResponse

uploadImage : String -> String -> Cmd Msg
uploadImage img token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token)
          , ("img", JsonEnc.string img)
          ]
  in
      Http.post "http://localhost:3001/api/users/new_image" body (decodeApiResponse <| Just decodeSessionUser)
      |> RemoteData.sendRequest
      |> Cmd.map (UpdateFieldResponse token)

delImg : Int -> String -> Cmd Msg
delImg id_ token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token)
          , ("id_img", JsonEnc.int id_)
          ]
  in
      Http.post "http://localhost:3001/api/users/del_image" body (decodeApiResponse <| Just decodeSessionUser)
      |> RemoteData.sendRequest
      |> Cmd.map (UpdateFieldResponse token)
