module Commands exposing (..)

import Api.ApiDecoder exposing (..)
import Http
import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Json.Encode as JsonEnc exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import RemoteData exposing (..)
import Talk.TalkDecoder exposing (..)
import Talk.TalkModel exposing (..)
import User.UserDecoder exposing (..)
import User.UserModel exposing (..)


decodeAuthResponse : Decoder AuthResponse
decodeAuthResponse =
    JsonDec.map4 AuthResponse
        (at [ "status" ] JsonDec.string)
        (maybe (at [ "msg" ] JsonDec.string))
        (maybe (at [ "token" ] JsonDec.string))
        (maybe (at [ "data" ] decodeSessionUser))


sendLogin : String -> String -> Cmd Msg
sendLogin login pwd =
    let
        body =
            Http.jsonBody <| JsonEnc.object [ ( "login", JsonEnc.string login ), ( "password", JsonEnc.string pwd ) ]
    in
    Http.post "http://localhost:3001/auth" body decodeAuthResponse
        |> RemoteData.sendRequest
        |> Cmd.map LoginResponse


resetPwd : String -> String -> Cmd Msg
resetPwd login email =
    let
        body =
            Http.jsonBody <| JsonEnc.object [ ( "username", JsonEnc.string login ), ( "email", JsonEnc.string email ) ]
    in
    Http.post "http://localhost:3001/auth/reset_password" body (decodeApiResponse <| Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map ResetPwdResponse


sendFastNewUser : String -> String -> String -> String -> String -> String -> Cmd Msg
sendFastNewUser username fname lname email pwd repwd =
    let
        body =
            Http.jsonBody <|
                JsonEnc.object
                    [ ( "username", JsonEnc.string username )
                    , ( "fname", JsonEnc.string fname )
                    , ( "lname", JsonEnc.string lname )
                    , ( "email", JsonEnc.string email )
                    , ( "password", JsonEnc.string pwd )
                    , ( "rePassword", JsonEnc.string repwd )
                    ]
    in
    Http.post "http://localhost:3001/auth/newfast" body (decodeApiResponse Nothing)
        |> RemoteData.sendRequest
        |> Cmd.map NewUserResponse
