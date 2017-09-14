module Login exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Models exposing (..)

view : LoginRoute -> Model -> Html Msg
view route model =
    case route of 
        Login -> 
            div [ class "container" ]
            <| [  div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ h1 [] [text "Connection"] ]
                ]
            ] 
            ++
             ( case model.message of
                Just msg -> 
                    [ div [ class "row"]
                        [ div [class "twelve columns"] [text msg]]
                    ] 
                _ -> []) ++

            [ div [ class "row" ]
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
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ a [ href "/#/signin" ][ text "Créer un compte" ] ]
                ]
            ]
        
        Signin ->
            div [ class "container" ]
            <| [  div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ h1 [] [text "Nouvel utilisateur"] ]
                ]
            ] 
            ++
             ( case model.message of
                Just msg -> 
                    [ div [ class "row"]
                        [ div [class "twelve columns"] [text msg]]
                    ] 
                _ -> []) ++

            [ div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "username" ] [ text "Nom d'utilisateur" ]
                    , input [ id "username", type_ "text" ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "email" ] [ text "Email" ]
                    , input [ id "email", type_ "email" ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "password" ] [ text "Mot de passe" ]
                    , input [ id "password", type_ "password" ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "repassword" ] [ text "Confirmation mot de passe" ]
                    , input [ id "repassword", type_ "password" ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ button [ onClick SendLogin ][text "Créer"] ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ a [ href "#/login" ][ text "J'ai déjà un compte" ] ]
                ]
            ]

