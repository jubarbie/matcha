module Commands exposing (..)

import Http
import Task
import Time
import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Json.Encode as JsonEnc exposing (..)
import RemoteData exposing (..)
import Models exposing (..)
import UserModel exposing (..)
import Msgs exposing (..)

decodeLocalisationResponse : Decoder LocalisationApi
decodeLocalisationResponse =
  JsonDec.map3 LocalisationApi
  (at ["status"] JsonDec.string)
  (maybe (at ["lon"] JsonDec.float))
  (maybe (at ["lat"] JsonDec.float))

usersDecoder : Decoder (List User)
usersDecoder =
    JsonDec.list decodeUser

gendersDecoder : Decoder (List Gender)
gendersDecoder =
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
  JsonDec.map3 Message
  (at ["date"] JsonDec.string)
  (at ["message"] JsonDec.string)
  (at ["username"] JsonDec.string)

decodeLocalisation : Decoder Localisation
decodeLocalisation =
  JsonDec.map2 Localisation
    (at ["lon"] JsonDec.float)
    (at ["lat"] JsonDec.float)

decodeUser : Decoder User
decodeUser =
  JsonDec.succeed User
    |: (field "login" JsonDec.string)
    |: (field "fname" JsonDec.string)
    |: (field "lname" JsonDec.string)
    |: (field "email" JsonDec.string)
    |: maybe (field "gender" decodeGender)
    |: maybe (field "interested_in" decodeGender)
    |: (field "bio" JsonDec.string)
    |: (field "talks" decodeTalks)
    |: maybe (field "localisation" decodeLocalisation)
    |: (field "photos" (JsonDec.list JsonDec.string))
    |: (field "rights" decodeRole)
    |: (field "activated" decodeUserStatus)

decodeCurrentUser : Decoder CurrentUser
decodeCurrentUser =
  JsonDec.succeed CurrentUser
    |: (field "login" JsonDec.string)
    |: maybe (field "gender" decodeGender)
    |: (field "bio" JsonDec.string)
    |: (field "match" decodeMatch)
    |: (field "has_talk" JsonDec.bool)
    |: (field "photos" (JsonDec.list JsonDec.string))


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
    (maybe (at ["data"] decodeUser))

getUsers : String -> Cmd Msg
getUsers token  =
    let
        body =
            Http.jsonBody <| JsonEnc.object [("token", JsonEnc.string token)]
    in
        Http.post "http://localhost:3001/api/admin/all_users" body (decodeApiResponse <| Just usersDecoder)
        |> RemoteData.sendRequest
        |> Cmd.map UsersResponse

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

getCurrentUser : String -> String -> Cmd Msg
getCurrentUser user token  =
    let
        body =
            Http.jsonBody <| JsonEnc.object [("token", JsonEnc.string token)]
    in
        Http.post ("http://localhost:3001/api/users/current_user/" ++ user) body (decodeApiResponse <| Just decodeCurrentUser)
        |> RemoteData.sendRequest
        |> Cmd.map CurrentUserResponse

getProfile : String -> String -> Cmd Msg
getProfile user token  =
    let
        body =
            Http.jsonBody <| JsonEnc.object [("token", JsonEnc.string token)]
    in
        Http.post ("http://localhost:3001/api/users/user/" ++ user) body (decodeApiResponse <| Just decodeUser)
        |> RemoteData.sendRequest
        |> Cmd.map (ProfileResponse token)

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

sendFastNewUser : String -> String -> String -> String -> Cmd Msg
sendFastNewUser username email pwd repwd =
    let
        body =
            Http.jsonBody <| JsonEnc.object
            [ ("username", JsonEnc.string username)
            , ("email", JsonEnc.string email)
            , ("password", JsonEnc.string pwd)
            , ("rePassword", JsonEnc.string repwd)
            ]
    in
        Http.post "http://localhost:3001/auth/newfast" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map NewUserResponse


updateAccountInfos : String -> String -> String -> String -> String -> String -> String -> Cmd Msg
updateAccountInfos token fname lname email gender intIn bio =
    let
        body =
            Http.jsonBody <| JsonEnc.object
            [ ("token", JsonEnc.string token)
            , ("email", JsonEnc.string email)
            , ("fname", JsonEnc.string fname)
            , ("lname", JsonEnc.string lname)
            , ("gender", JsonEnc.string gender)
            , ("int_in", JsonEnc.string intIn)
            , ("bio", JsonEnc.string bio)
            ]
    in
        Http.post "http://localhost:3001/api/users/update" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map (EditAccountResponse email fname lname gender intIn bio)

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
sendMessage token username message =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token)
          , ("username", JsonEnc.string username)
          , ("message", JsonEnc.string message)
          ]
  in
      Http.post "http://localhost:3001/api/talks/new_message/" body (decodeApiResponse <| Just talkDecoder )
      |> RemoteData.sendRequest
      |> Cmd.map GetTalkResponse

getIpLocalisation : Cmd Msg
getIpLocalisation =
    Http.get "http://ip-api.com/json" decodeLocalisationResponse
    |> RemoteData.sendRequest
    |> Cmd.map GetIpLocalisation

saveLocation : String -> Localisation -> Cmd Msg
saveLocation token loc =
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
