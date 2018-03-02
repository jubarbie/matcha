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
import Task exposing (..)


init : Location -> ( Model, Cmd Msg )
init location =
  let
    model =
        case Routing.parseAppLocation location of
          NotFoundAppRoute ->
            case Routing.parseLoginLocation location of
              NotFoundLoginRoute -> Connexion NotFoundAppRoute
              route -> NotConnected route initialLoginModel
          route -> Connexion route
  in
    ( model, getToken () )

subscriptions : Model -> Sub Msg
subscriptions model =
  case model of
    Connected route session appModel ->
        let
          subRoute =
            case route of
              AccountRoute -> Time.every Time.second LoadMap
              _ -> Sub.none

          subAnim =
            case appModel.matchAnim of
              Just t -> Time.every Time.millisecond UpdateAnim
              _ -> Sub.none
        in
          Sub.batch [ tokenRecieved SaveToken
                    , newLocalisation SetNewLocalisation
                    , fileContentRead ImageRead
                    , subAnim
                    , subRoute
                    , Time.every Time.second UpdateCurrentTime
                    , WebSocket.listen "ws://localhost:3001/ws" Notification
                    ]
    _ -> Sub.none

main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
      { init = init
      , subscriptions = subscriptions
      , view = view
      , update = Update.update
      }
