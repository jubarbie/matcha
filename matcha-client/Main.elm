module Main exposing (..)

import Navigation exposing (Location)
import Routing exposing (..)
import WebSocket
import Time

import Views exposing (view)
import Models exposing (..)
import Msgs exposing (..)
import Update exposing (..)
import Ports exposing (getToken, tokenRecieved, localize, newLocalisation)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location
        cmd = case currentRoute of
            UsersRoute -> Cmd.none
            _ -> Cmd.none
    in
        ( initialModel currentRoute, Cmd.batch [cmd, getToken ()])

subscriptions : Model -> Sub Msg
subscriptions model =
  let
    subRoute =
      case model.route of
        ChatRoute a -> Time.every Time.second (FetchTalk a)
        AccountRoute -> Time.every Time.second LoadMap
        _ -> Sub.none

    subAnim =
      case model.matchAnim of
        Just t -> Time.every Time.millisecond UpdateAnim
        _ -> Sub.none
  in
    Sub.batch [ tokenRecieved SaveToken
              , newLocalisation SetNewLocalisation
              , subAnim
              , subRoute
              ]

main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
    { init = init
    , subscriptions = subscriptions
    , view = view
    , update = Update.update
    }
