module Account exposing (view)

import Html exposing (..)
import Models exposing (..)


view : Model ->  Html Msg
view model =
    div []
        [ text "account" ]
