module Login exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import FormUtils exposing (..)

view : LoginRoute -> Model -> Html Msg
view route model =
    let msg =
        case model.message of
            Just msg -> msg
            _ -> ""
    in
      div [ class <| if msg /= "" then "wrong" else "" ]
          [ img [ src "/assets/images/DARKROOM_logo.svg", id "logo" ] []
          , div [][text msg]
          , (case route of
              Login -> Html.Keyed.node "div" [] [("div", viewLoginForm model)]
              Signin -> Html.Keyed.node "sign" [] [("div", viewNewUserForm model)]
              ResetPwdRoute -> Html.Keyed.node "rest" [] [("div", viewResetPwdForm model)])
          ]

viewLoginForm : Model -> Html Msg
viewLoginForm model =
    div [] <| List.map (\i -> viewInput (UpdateLoginForm i.id) i) model.loginForm
        ++ [ div [onClick SendLogin, class "important-font"  ][ text "ENTER" ]
            , div [ class "row" ]
            [ div [class "twelve columns"] [ a [ href "#/signin" ][ text "Create new account" ] ]
            , div [class "twelve columns"] [a [ href "#/password_reset" ][ text "Forgot password ?" ]]
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

viewResetPwdForm : Model -> Html Msg
viewResetPwdForm model =
    div []
        [ p [] [ text "In order to reset your password, please give us your login and the email you used when you created your account. You'll recieve an email with your new password" ]
        , div [] <| List.map (\i -> viewInput (UpdateResetPwdForm i.id) i) model.resetPwdForm
          ++
            [ div [ onClick ResetPwd, class "important-font" ][ text "Reset my password" ] ]
        ]
