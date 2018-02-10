module Talk.TalkDecoder exposing (..)

import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Json.Encode as JsonEnc exposing (..)
import Talk.TalkModel exposing (..)


decodeTalks : Decoder (List Talk)
decodeTalks =
    JsonDec.list decodeTalk


decodeTalk : Decoder Talk
decodeTalk =
    JsonDec.succeed Talk
        |: field "username" JsonDec.string
        |: field "unread" JsonDec.int
        |: field "messages" (JsonDec.list decodeMessage)
        |: field "new_message" JsonDec.string


talkDecoder : Decoder (List Message)
talkDecoder =
    JsonDec.list decodeMessage


decodeMessage : Decoder Message
decodeMessage =
    JsonDec.succeed Message
        |: field "date" JsonDec.string
        |: field "message" JsonDec.string
        |: field "username" JsonDec.string
