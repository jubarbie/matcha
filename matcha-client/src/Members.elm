module Members exposing (view)

import Html exposing (..)
import RemoteData exposing (..)

import Models exposing (..)


view : Model -> Html Msg
view model =
            div []
                [ viewMembers model.users
            ]

viewMembers : List User -> Html msg
viewMembers users =
    div 
    [] 
    <| h1 [][text "Les membres"] :: List.map (\u -> div [][text u.fname, text " ",text u.lname]) users

