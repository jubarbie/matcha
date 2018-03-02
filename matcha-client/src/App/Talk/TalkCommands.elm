module App.Talk.TalkCommands exposing (..)

import Http
import Json.Encode as JsonEnc exposing (..)
import App.Talk.TalkDecoder exposing (..)
import WebSocket
import Msgs exposing (..)
import RemoteData exposing (..)
import Api.ApiDecoder exposing (..)
import Api.ApiRequest exposing (..)


getTalk : String -> Bool -> String -> Cmd Msg
getTalk username update token =
    let
        url = "http://localhost:3001/api/talks/talk/" ++ username
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "update", JsonEnc.bool update ) ]
    in
      Http.send GetTalkResponse (apiPostRequest (Just decodeTalk) token url body)


getTalks : String -> Cmd Msg
getTalks token =
    let
        url = "http://localhost:3001/api/talks/all_talks/"
    in
        Http.send GetTalksResponse (apiGetRequest (Just decodeTalks) token url)


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
