module User.UserDecoder exposing (..)

import User.UserModel exposing (..)
import Json.Decode as JsonDec exposing (..)
import Json.Decode.Extra exposing (..)
import Json.Encode as JsonEnc exposing (..)

decodeLocalisationResponse : Decoder LocalisationApi
decodeLocalisationResponse =
    JsonDec.map3 LocalisationApi
        (at [ "status" ] JsonDec.string)
        (maybe (at [ "lon" ] JsonDec.float))
        (maybe (at [ "lat" ] JsonDec.float))


encodeIntIn : List Gender -> JsonEnc.Value
encodeIntIn intIn =
    JsonEnc.list (List.map (\g -> JsonEnc.string <| genderToString <| Just g) intIn)


usersDecoder : Decoder (List User)
usersDecoder =
    JsonDec.list decodeUser

usersSessionDecoder : Decoder (List SessionUser)
usersSessionDecoder =
    JsonDec.list decodeSessionUser


decodeIntIn : Decoder (List Gender)
decodeIntIn =
    JsonDec.list decodeGender


decodeGender : Decoder Gender
decodeGender =
    JsonDec.string
        |> JsonDec.andThen
            (\a ->
                case a of
                    "M" ->
                        JsonDec.succeed M

                    "F" ->
                        JsonDec.succeed F

                    _ ->
                        JsonDec.fail "Gender must be M or F"
            )


decodeUserStatus : Decoder UserStatus
decodeUserStatus =
    JsonDec.string
        |> JsonDec.andThen
            (\a ->
                case a of
                    "activated" ->
                        JsonDec.succeed Activated

                    "resetpwd" ->
                        JsonDec.succeed ResetPassword

                    "incomplete" ->
                        JsonDec.succeed Incomplete

                    _ ->
                        JsonDec.succeed NotActivated
            )


decodeLocalisation : Decoder Localisation
decodeLocalisation =
    JsonDec.succeed Localisation
        |: field "lon" JsonDec.float
        |: field "lat" JsonDec.float


decodeSessionUser : Decoder SessionUser
decodeSessionUser =
    JsonDec.succeed SessionUser
        |: field "login" JsonDec.string
        |: field "fname" JsonDec.string
        |: field "lname" JsonDec.string
        |: field "email" JsonDec.string
        |: maybe (field "gender" decodeGender)
        |: field "interested_in" decodeIntIn
        |: field "bio" JsonDec.string
        |: field "birth" JsonDec.int
        |: field "tags" (JsonDec.list JsonDec.string)
        |: maybe (field "localisation" decodeLocalisation)
        |: field "photos" decodeImgs
        |: field "rights" decodeRole
        |: field "activated" decodeUserStatus

decodeImgs : Decoder (List ( Int, String ))
decodeImgs =
    JsonDec.list <| arrayAsTuple2 JsonDec.int JsonDec.string


decodeUser : Decoder User
decodeUser =
    JsonDec.succeed User
        |: field "login" JsonDec.string
        |: maybe (field "gender" decodeGender)
        |: field "bio" JsonDec.string
        |: field "birth" JsonDec.int
        |: field "liking" JsonDec.bool
        |: field "liked" JsonDec.bool
        |: field "has_talk" JsonDec.bool
        |: field "visitor" JsonDec.bool
        |: field "tags" (JsonDec.list JsonDec.string)
        |: field "photos" (JsonDec.list JsonDec.string)
        |: field "last_connection" JsonDec.string
        |: maybe (field "distance" JsonDec.float)


decodeRole : Decoder UserRole
decodeRole =
    JsonDec.int
        |> JsonDec.andThen
            (\a ->
                case a of
                    0 ->
                        JsonDec.succeed ADMIN

                    1 ->
                        JsonDec.succeed USER

                    _ ->
                        JsonDec.fail "Unknown role"
            )

arrayAsTuple2 : Decoder a -> Decoder b -> Decoder ( a, b )
arrayAsTuple2 a b =
    index 0 a
        |> JsonDec.andThen
            (\aVal ->
                index 1 b
                    |> JsonDec.andThen (\bVal -> JsonDec.succeed ( aVal, bVal ))
            )
