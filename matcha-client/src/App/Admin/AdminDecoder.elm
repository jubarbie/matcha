module App.Admin.AdminDecoder exposing (..)

import App.User.UserModel exposing (..)
import App.User.UserDecoder exposing (..)
import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Json.Encode as JsonEnc exposing (..)


decodeAdminUsers : Decoder (List SessionUser)
decodeAdminUsers =
    JsonDec.list decodeSessionUser
