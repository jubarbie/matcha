module Views exposing (view)

import Html exposing (..)

import Models exposing (..)
import Members exposing (view)
import Login exposing (view)

view : Model -> Html Msg
view model =
    case model.route of
        Login ->
            Login.view model
        Members ->
            Members.view model
        NotFoundRoute ->
            div [][text "401 not found"]
