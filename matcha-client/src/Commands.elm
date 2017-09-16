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

stringToGender : String -> ValidationForm Gender
stringToGender g =
    case g of
        "M" -> Valid M
        "F" -> Valid F
        _ -> NotValid "Must be F or M"

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
    JsonDec.map6 User
    (at ["fname"] JsonDec.string)
    (at ["lname"] JsonDec.string)
    (at ["email"] JsonDec.string)
    (at ["gender"] decodeGender)
    (at ["interested_in"] decodeGender)
    (at ["bio"] JsonDec.string)

decodeApiResponse : Decoder ApiResponse
decodeApiResponse =
    JsonDec.map2 ApiResponse
    (at ["status"] JsonDec.string)
    (maybe (at ["msg"] JsonDec.string))

decodeAuthResponse : Decoder AuthResponse
decodeAuthResponse =
    JsonDec.map3 AuthResponse
    (at ["status"] JsonDec.string)
    (maybe (at ["msg"] JsonDec.string))
    (maybe (at ["token"] JsonDec.string))

getUsers : String -> Cmd Msg
getUsers token  =
    let
        body = 
            Http.jsonBody <| JsonEnc.object [("token", JsonEnc.string token)]
    in
        Http.post "http://localhost:3001/api/users" body usersDecoder
        |> RemoteData.sendRequest
        |> Cmd.map UsersResponse

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
        Http.post "http://localhost:3001/api/users/new" body decodeApiResponse
        |> RemoteData.sendRequest
        |> Cmd.map HandleApiResponse
