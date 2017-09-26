module Commands exposing (..)

import Http
import Json.Decode as JsonDec exposing (..)
import Json.Encode as JsonEnc exposing (..)
import RemoteData exposing (..)
import Models exposing (..)
import Msgs exposing (..)


genderToString : Gender -> String
genderToString g =
    case g of
        M -> "M"
        F -> "F"

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

decodeUser : Decoder User
decodeUser =
    JsonDec.map7 User
    (at ["login"] JsonDec.string)
    (at ["fname"] JsonDec.string)
    (at ["lname"] JsonDec.string)
    (at ["email"] JsonDec.string)
    (at ["gender"] decodeGender)
    (at ["interested_in"] decodeGender)
    (at ["bio"] JsonDec.string)

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
        Http.post "http://localhost:3001/api/users" body usersDecoder
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
        |> Cmd.map (UserResponse token)

sendLogin : String -> String -> Cmd Msg
sendLogin login pwd =
    let
        body = 
            Http.jsonBody <| JsonEnc.object [("login", JsonEnc.string login), ("password", JsonEnc.string pwd)]
    in
        Http.post "http://localhost:3001/auth" body decodeAuthResponse
        |> RemoteData.sendRequest
        |> Cmd.map LoginResponse

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
        Http.post "http://localhost:3001/api/users/new" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map NewUserResponse
