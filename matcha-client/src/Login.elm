module Login exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Models exposing (..)
import Msgs exposing (..)

view : LoginRoute -> Model -> Html Msg
view route model =
    case route of 
        Login -> viewLoginForm model 

        Signin -> viewNewUserForm model

viewLoginForm : Model -> Html Msg
viewLoginForm model =
    div [] <| List.map (\i -> viewInput (UpdateLoginForm i.id) i) model.loginForm
    ++ [ button [onClick SendLogin ][ text "Connection" ]
        , div [ class "row" ]
        [ div [class "twelve columns"] 
        [ a [ href "#/signin" ][ text "Créer un compte" ] ]
        ]
        ]

viewNewUserForm : Model -> Html Msg
viewNewUserForm model =
        div [] <| List.map (\i -> viewInput (UpdateNewUserForm i.id) i) model.newUserForm
        ++ 
        [ button [onClick NewUser ][ text "Créer" ] 
        , div [ class "row" ]
        [ div [class "twelve columns"] 
        [ a [ href "#/login" ][ text "J'ai déjà un compte" ] ]
        ]
        ]

viewInput : (String -> Msg) -> Input -> Html Msg
viewInput mess i =
    let 
        inputClass = case i.status of 
            NotValid err -> "input input-error"
            Valid a -> "input input-success"
            Waiting -> "input"
    in
        div [ class inputClass]
            [ label [ for i.id ] [ text i.label ]
            , input [ type_ i.typ, id i.id, onInput mess ] []
            , case i.tip of
                Just tip -> div [ class "input-tip" ][ text tip ]
                _ -> div [][]
            ]
