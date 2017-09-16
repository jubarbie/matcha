module Chat exposing (view)

import Html exposing (..)

import Models exposing (..)
import Msgs exposing (..)


view : Model -> Html Msg
view model =
    div []
        [text "chat"]
