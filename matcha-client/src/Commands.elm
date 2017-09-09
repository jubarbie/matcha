module Commands exposing (..)

import Http
import Json.Decode exposing (..)
import RemoteData exposing (..)

import Models exposing (..)

usersDecoder : Decoder (List User)
usersDecoder =
    list decodeUser

decodeUser : Decoder User
decodeUser =
   Json.Decode.map2 User
    (at ["fname"] string)
    (at ["lname"] string)

getUsers : Cmd Msg
getUsers =
        Http.get "http://localhost:3001/users" usersDecoder
                |> RemoteData.sendRequest
                |> Cmd.map UsersResponse
