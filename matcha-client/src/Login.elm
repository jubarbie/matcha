module Login exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Models exposing (..)

view : Model -> Html Msg
view model =
            div [ class "container" ]
            [  div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ h1 [] [text "Connection"] ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "login" ] [ text "Login" ]
                    , input [ id "login", type_ "text", onInput UpdateLoginInput ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "password" ] [ text "Mot de passe" ]
                    , input [ id "password", type_ "password", onInput UpdatePasswordInput ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ button [ onClick SendLogin ][text "Connection"] ]
                ]
            ]
