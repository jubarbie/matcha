module Talk.TalkCommands exposing (..)

import Http
import Json.Encode as JsonEnc exposing (..)
import Talk.TalkDecoder exposing (..)
import WebSocket
import Msgs exposing (..)
import RemoteData exposing (..)
import Api.ApiDecoder exposing (..)


getTalk : String -> Bool -> String -> Cmd Msg
getTalk username update token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token )
                    , ( "update", JsonEnc.bool update )
                    ]
    in
    Http.post ("http://localhost:3001/api/talks/talk/" ++ username) body (decodeApiResponse <| Just decodeTalk)
        |> RemoteData.sendRequest
        |> Cmd.map GetTalkResponse


getTalks : String -> Cmd Msg
getTalks token =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "token", JsonEnc.string token ) ]
    in
    Http.post "http://localhost:3001/api/talks/all_talks/" body (decodeApiResponse <| Just decodeTalks)
        |> RemoteData.sendRequest
        |> Cmd.map GetTalksResponse


sendMessage : String -> String -> String -> Cmd Msg
sendMessage token to message =
    let
        body =
            JsonEnc.encode 0 <|
                JsonEnc.object
                    [ ( "jwt", JsonEnc.string token )
                    , ( "action", JsonEnc.string "new_message" )
                    , ( "to", JsonEnc.string to )
                    , ( "message", JsonEnc.string message )
                    ]
    in
        WebSocket.send "ws://localhost:3001/ws" body
