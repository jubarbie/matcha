module Views exposing (view)

import Html exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import App.AppViews exposing (view)
import Login.LoginView exposing (view)


view : Model -> Html Msg
view model =
  case model of
    NotConnected route loginModel ->
      Login.LoginView.view route loginModel
    Connexion route ->
      connectionView
    Connected route session appModel ->
      App.AppViews.view route session appModel

connectionView : Html Msg
connectionView =
  div [] [ text "connexion..."]
