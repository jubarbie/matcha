module Account exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Mapbox.Maps.SlippyMap as Mapbox
import Mapbox.Endpoint as Endpoint


view : Model ->  Html Msg
view model =
    case model.session of
        Just s -> viewAccount model s.user
        _ -> text "no session..."

viewAccount : Model -> User -> Html Msg
viewAccount model user =
    div []
      [ h1 [] [text "Account"]
      , div [] [text user.username]
      , div [] [text user.fname, text " ",text user.lname]
      , div [] [text user.email]
      , div [] [text user.bio]
      , div [ id "map" ] []
      , button [ onClick Localize ][ text "Localize me" ]
      ]
