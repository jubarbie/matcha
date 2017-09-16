module Login exposing (view)

import Html exposing (..)
import Html.Keyed as K exposing (node)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Models exposing (..)
import Msgs exposing (..)

view : LoginRoute -> Model -> Html Msg
view route model =
    case route of 
        Login ->
            K.node "div" [] [ 
            ("div", div [ class "container" ]
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
            ])]
        
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
                    <| inputWithValid 
                        model.newUserForm.username
                        [ id "username", type_ "text", onInput UpdateUsernameInput ] 
                        [ for "username" ]
                        "Nom d'utilisateur"
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "fname" ] [ text "Prénom" ]
                    , input [ id "fname", type_ "text", onInput UpdateFnameInput][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "lname" ] [ text "Nom" ]
                    , input [ id "lname", type_ "text", onInput UpdateLnameInput][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "email" ] [ text "Email" ]
                    , input [ id "email", type_ "email", onInput UpdateEmailInput ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "password" ] [ text "Mot de passe" ]
                    , input [ id "password", type_ "password", onInput UpdatePwdInput][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "repassword" ] [ text "Confirmation mot de passe" ]
                    , input [ id "repassword", type_ "password", onInput UpdateRePwdInput ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "gender" ] [ text "Genre" ]
                    , input [ id "gender", type_ "text", onInput UpdateGenderInput ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "intIn" ] [ text "Intéressé pas" ]
                    , input [ id "intIn", type_ "text", onInput UpdateIntInInput ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ label [ for "bio" ] [ text "Bio" ]
                    , input [ id "bio", type_ "text", onInput UpdateBioInput ][] 
                    ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ button [ onClick NewUser ][text "Créer"] ]
                ]
            , div [ class "row" ]
                [ div [class "twelve columns"] 
                    [ a [ href "#/login" ][ text "J'ai déjà un compte" ] ]
                ]
            ]

inputView : Input a -> List (Attribute b) -> List (Attribute b) -> String -> List (Html b)
inputWithValid inpt attr lattr ltext =
    let 
        val = inpt.validation
        iattr = case val of
            NotValid err -> class "form-error" :: attr
            _ -> attr
    in 
    [ label lattr [ text ltext ]
    , input iattr []
    ] ++ 
    case val of 
        NotValid err -> [ div [class "tip-error"] [text err] ]
        _ -> []
