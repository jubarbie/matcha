module Commands exposing (..)

import Http
import Json.Decode as JsonDec exposing (..)
import Json.Encode as JsonEnc exposing (..)
import RemoteData exposing (..)
import Models exposing (..)
import Msgs exposing (..)


genderToString : Maybe Gender -> String
genderToString g =
    case g of
        Just M -> "M"
        Just F -> "F"
        _ -> "No gender"

stringToGender : String -> Maybe Gender
stringToGender g =
    case g of
        "M" -> Just M
        "F" -> Just F
        _ -> Nothing

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
  (at ["user"] JsonDec.string)

decodeUser : Decoder User
decodeUser =
    JsonDec.map8 User
    (at ["login"] JsonDec.string)
    (at ["fname"] JsonDec.string)
    (at ["lname"] JsonDec.string)
    (at ["email"] JsonDec.string)
    (maybe (at ["gender"] decodeGender))
    (maybe (at ["interested_in"] decodeGender))
    (at ["bio"] JsonDec.string)
    (at ["talks"] decodeTalks)

decodeCurrentUser : Decoder CurrentUser
decodeCurrentUser =
  JsonDec.map5 CurrentUser
  (at ["login"] JsonDec.string)
  (maybe (at ["gender"] decodeGender))
  (at ["bio"] JsonDec.string)
  (at ["liked"] JsonDec.bool)
  (maybe (at ["talk_id"] JsonDec.int))


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

getUsers : String -> String -> Cmd Msg
getUsers user token  =
    let
        body =
            Http.jsonBody <| JsonEnc.object [("token", JsonEnc.string token), ("user", JsonEnc.string user)]
    in
        Http.post "http://localhost:3001/api/users/all_users" body usersDecoder
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
        Http.post "http://localhost:3001/api/users/newfast" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map NewUserResponse

sendNewUser : String -> String -> String -> String -> String -> String -> String -> String -> String -> Cmd Msg
sendNewUser username fname lname email pwd repwd gender intIn bio =
    let
        body =
            Http.jsonBody <| JsonEnc.object
            [ ("username", JsonEnc.string username)
            , ("email", JsonEnc.string email)
            , ("fname", JsonEnc.string fname)
            , ("lname", JsonEnc.string lname)
            , ("password", JsonEnc.string pwd)
            , ("rePassword", JsonEnc.string repwd)
            , ("gender", JsonEnc.string gender)
            , ("int_in", JsonEnc.string intIn)
            , ("bio", JsonEnc.string bio)
            ]
    in
        Http.post "http://localhost:3001/api/users/newfast" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map NewUserResponse

deleteUser : String -> String -> Cmd Msg
deleteUser username token =
    let
        body =
            Http.jsonBody <| JsonEnc.object
            [ ("username", JsonEnc.string username)
            , ("token", JsonEnc.string token)
            ]
    in
        Http.post "http://localhost:3001/api/users/delete_user" body (decodeApiResponse Nothing)
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
        Http.post "http://localhost:3001/api/users/toggle_like" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map (ToggleLikeResponse username)

getTalk : String -> String -> Cmd Msg
getTalk username token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token) ]
  in
      Http.post ("http://localhost:3001/api/users/talk/" ++ username) body (decodeApiResponse <| Just talkDecoder )
      |> RemoteData.sendRequest
      |> Cmd.map GetTalkResponse

getTalks : String -> Cmd Msg
getTalks token =
  let
      body =
          Http.jsonBody <| JsonEnc.object
          [ ("token", JsonEnc.string token) ]
  in
      Http.post "http://localhost:3001/api/users/all_talks/" body (decodeApiResponse <| Just decodeTalks )
      |> RemoteData.sendRequest
      |> Cmd.map GetTalksResponse
