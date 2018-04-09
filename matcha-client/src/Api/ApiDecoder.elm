module Api.ApiDecoder exposing (..)

import Api.ApiModel exposing (..)
import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)


decodeApiResponse : Maybe (Decoder a) -> Decoder (ApiResponse (Maybe a))
decodeApiResponse decoder =
    case decoder of
        Just d ->
            JsonDec.map3 ApiResponse
                (at [ "status" ] JsonDec.bool)
                (maybe (at [ "msg" ] JsonDec.string))
                (maybe (at [ "data" ] d))

        _ ->
            JsonDec.map3 ApiResponse
                (at [ "status" ] JsonDec.bool)
                (maybe (at [ "msg" ] JsonDec.string))
                (JsonDec.succeed Nothing)
