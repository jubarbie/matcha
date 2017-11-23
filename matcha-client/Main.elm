module Main exposing (..)

import Navigation exposing (Location)
import Routing exposing (..)
import WebSocket
import Time

import Views exposing (view)
import Models exposing (..)
import Msgs exposing (..)
import Update exposing (..)
import Ports exposing (..)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location
    in
        ( initialModel currentRoute, getToken ())

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
              , fileContentRead ImageRead
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
