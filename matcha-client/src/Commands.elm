module Commands exposing (..)

import Http
import Json.Decode as JsonDec exposing (..)
import Json.Encode as JsonEnc exposing (..)
import RemoteData exposing (..)
import Models exposing (..)

usersDecoder : Decoder (List User)
usersDecoder =
    JsonDec.list decodeUser

decodeUser : Decoder User
decodeUser =
    JsonDec.map2 User
    (at ["fname"] JsonDec.string)
    (at ["lname"] JsonDec.string)

decodeApiResponse : Decoder ApiResponse
decodeApiResponse =
    JsonDec.map3 ApiResponse
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
        Http.post "http://localhost:3001/auth" body decodeApiResponse
        |> RemoteData.sendRequest
        |> Cmd.map HttpResponse
