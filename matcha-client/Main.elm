import Html exposing (..)
import Json.Decode exposing (..)
import RemoteData exposing (..)
import Navigation exposing (Location)
import Routing exposing (..)

import Views exposing (view)
import Models exposing (..)
import Update exposing (..)
import Commands exposing (..)

initUsers : Value -> List User
initUsers data =
    case usersDecoder data of
        Ok val -> val
        _ -> [User "Error" "Error"]

usersDecoder : Value -> Result String (List User)
usersDecoder data =
    decodeValue (list decodeUser) data

decodeUser : Decoder User
decodeUser =
    Json.Decode.map2 User
    (at ["fname"] string)
    (at ["lname"] string)

initialModel : Route -> Model
initialModel route =
    { route = route
    , token = Nothing
    , loginInput =  {input = "", value = "", validation = (False, "")}
    , passwordInput =  {input = "", value = "", validation = (False, "")} 
    , users = []
    , message = Nothing
    }

init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location
        cmd = case currentRoute of
            Members -> getUsers ""
            _ -> Cmd.none
    in
        ( initialModel currentRoute, cmd )


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
    { init = init
    , subscriptions = subscriptions
    , view = view
    , update = Update.update
    }
