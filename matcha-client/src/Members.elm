module Members exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (..)

import Models exposing (..)


view : Model -> Html Msg
view model =
    case model.route of
        Login -> 
            div []
            [ input [type_ "text", onInput UpdateInput ][] 
            , input [type_ "text", onInput UpdateInput ][]
            , button [onClick SendLogin ][text "Connection"]
            ]
        Members -> 
            div []
            [ viewMenu model 
            , (
                case model.users of
                    NotAsked -> text "Initialising."

                    Loading -> text "Loading."

                    Failure err -> text ("Error: " ++ toString err)

                    Success users -> viewMembers users
                )
            ]
        NotFoundRoute -> div [][text "401 not found"]

viewMembers : List User -> Html msg
viewMembers users =
    div 
    [] 
    <| h1 [][text "Les membresss"] :: List.map (\u -> div [][text u.fname, text " ",text u.lname]) users

viewMenu : Model -> Html msg
viewMenu model =
    nav [ class "main-nav" ]
    [ ul []
    [ li [] [ a [ href "http://localhost:3001/users" ] [ text "PARCOURIR" ] ]
    , li [] [ a [ href "http://localhost:3001/#chat" ] [ text "CHAT" ] ]
    , li [] [ a [ href "http://localhost:3001/account" ] [ text "MON COMPTE" ] ]
    ]
    ]
