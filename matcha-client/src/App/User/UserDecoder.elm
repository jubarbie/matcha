module App.User.UserDecoder exposing (..)

import App.User.UserModel exposing (..)
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

                    "NB" ->
                        JsonDec.succeed NB

                    "O" ->
                        JsonDec.succeed O

                    _ ->
                        JsonDec.fail "Gender must be M, F, NB or O"
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
        |: maybe (field "bio" JsonDec.string)
        |: maybe (field "birth" JsonDec.int)
        |: field "tags" (JsonDec.list JsonDec.string)
        |: field "localisation" decodeLocalisation
        |: field "images" decodeImgs
        |: field "activated" decodeUserStatus
        |: field "rights" decodeRights

decodeRights : Decoder UserRole
decodeRights =
  JsonDec.int
      |> JsonDec.andThen
          (\a ->
              case a of
                  0 ->
                      JsonDec.succeed ADMIN

                  _ ->
                      JsonDec.succeed USER
          )

decodeImgs : Decoder (List ( Int, String, Bool ))
decodeImgs =
    JsonDec.list <| arrayAsTuple3 JsonDec.int JsonDec.string JsonDec.bool


decodeUser : Decoder User
decodeUser =
    JsonDec.succeed User
        |: field "login" JsonDec.string
        |: maybe (field "gender" decodeGender)
        |: field "bio" JsonDec.string
        |: field "birth" JsonDec.int
        |: field "liking" JsonDec.bool
        |: field "liked" JsonDec.bool
        |: field "likes" JsonDec.int
        |: field "visits" JsonDec.int
        |: field "has_talk" JsonDec.bool
        |: field "visitor" JsonDec.bool
        |: field "tags" (JsonDec.list JsonDec.string)
        |: field "images" decodeImgs
        |: field "last_connection" JsonDec.string
        |: field "online" JsonDec.bool
        |: field "distance" JsonDec.float


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

arrayAsTuple3 : Decoder a -> Decoder b -> Decoder c -> Decoder ( a, b, c )
arrayAsTuple3 a b c =
    index 0 a
        |> JsonDec.andThen
            (\aVal ->
                index 1 b
                    |> JsonDec.andThen
                        (\bVal ->
                            index 2 c
                              |> JsonDec.andThen (\cVal -> JsonDec.succeed ( aVal, bVal, cVal ))
                        )
            )
