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
    JsonDec.map2 ApiResponse
        (at ["status"] JsonDec.string)
        (maybe (at ["msg"] JsonDec.string))

getUsers : Cmd Msg
getUsers =
        Http.get "http://localhost:3001/users" usersDecoder
                |> RemoteData.sendRequest
                |> Cmd.map UsersResponse

sendLogin : String -> String -> Cmd Msg
sendLogin login pwd =
    let
        body = 
            Http.jsonBody <| JsonEnc.object [("login", JsonEnc.string login), ("password", JsonEnc.string pwd)]
    in
        Http.post "http://localhost:3001/login" body decodeApiResponse
                |> RemoteData.sendRequest
                |> Cmd.map HttpResponse
