module Login exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed exposing (..)
import Models exposing (..)
import Msgs exposing (..)

view : LoginRoute -> Model -> Html Msg
view route model =
    let msg =
        case model.message of
            Just msg -> msg
            _ -> ""
    in
    div []
        [ img [ src "/assets/images/DARKROOM_logo.svg", id "logo" ] []
        , div [][text msg]
        , (case route of
            Login -> Html.Keyed.node "div" [] [("div", viewLoginForm model)]
            Signin -> Html.Keyed.node "sign" [] [("div", viewNewUserForm model)])
        ]

viewLoginForm : Model -> Html Msg
viewLoginForm model =
    div [] <| List.map (\i -> viewInput (UpdateLoginForm i.id) i) model.loginForm
        ++ [ div [onClick SendLogin, class "important-font"  ][ text "ENTER" ]
            , div [ class "row" ]
            [ div [class "twelve columns"]
            [ a [ href "#/signin" ][ text "Create new account" ] ]
            ]
        ]

viewNewUserForm : Model -> Html Msg
viewNewUserForm model =
        div [] <| List.map (\i -> viewInput (UpdateNewUserForm i.id) i) model.newUserForm
        ++
        [ div [ onClick NewUser, class "important-font" ][ text "Sign in" ]
        , div [ class "row" ]
        [ div [class "twelve columns"]
              [ a [ href "#/login" ][ text "I already have an account" ] ]
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
