module Commands exposing (..)

import Http
import Json.Decode as JsonDec exposing (..)
import Json.Encode as JsonEnc exposing (..)
import RemoteData exposing (..)
import Models exposing (..)

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
    (at ["inIn"] gendersDecoder)
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

sendNewUser : NewUserForm -> Cmd Msg
sendNewUser model =
    let
        gender = case model.gender.value of
            M -> "M"
            F -> "F"
        intIn = List.map (\i -> (
            case i of 
                M -> "M"
                F -> "F")
            ) model.intIn.value 
        body = 
            Http.jsonBody <| JsonEnc.object 
            [ ("username", JsonEnc.string model.username.value)
            , ("email", JsonEnc.string model.email.value)
            , ("password", JsonEnc.string model.password.value)
            , ("rePassword", JsonEnc.string model.rePassword.value)
            , ("gender", JsonEnc.string gender)
            , ("intIn", JsonEnc.list (List.map JsonEnc.string intIn))
            , ("bio", JsonEnc.string model.bio.value)
            ]
    in
        Http.post "http://localhost:3001/auth" body decodeAuthResponse
        |> RemoteData.sendRequest
        |> Cmd.map LoginResponse
