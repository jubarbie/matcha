module Login.LoginView exposing (view)

import FormUtils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed exposing (..)
import Json.Decode
import Models exposing (..)
import Login.LoginModels exposing (..)
import Msgs exposing (..)


view : LoginRoutes -> LoginModel -> Html Msg
view route model =
  let
    view =
    case route of
      LoginRoute ->
        viewLoginForm model

      SigninRoute ->
        Html.Keyed.node "sign" [] [ ( "div", viewNewUserForm model ) ]

      ResetPwdRoute ->
        Html.Keyed.node "rest" [] [ ( "div", viewResetPwdForm model ) ]

      NotFoundLoginRoute ->
        view404
   in
    div [ class "layout-column center" ]
        [ img [ src "http://localhost:3001/images/DARKROOM_logo.svg", alt "DARKROOM" ] []
        , view
        ]

view404 : Html Msg
view404 =
  div [][ text "404 not found" ]

viewLoginForm : LoginModel -> Html Msg
viewLoginForm model =
    Html.form [] <|
        List.map (\i -> viewInput (UpdateLoginForm i.id) i) model.loginForm
            ++ [ input
                    [ onWithOptions
                        "click"
                        { preventDefault = True
                        , stopPropagation = False
                        }
                        (Json.Decode.succeed SendLogin)
                    , class "important-font"
                    , type_ "submit"
                    , value "ENTER"
                    ]
                    []
               , div [ class "row" ]
                    [ div [ class "twelve columns" ] [ a [ href "#/signup" ] [ text "Create new account" ] ]
                    , div [ class "twelve columns" ] [ a [ href "#/password_reset" ] [ text "Forgot password ?" ] ]
                    ]
               ]


viewNewUserForm : LoginModel -> Html Msg
viewNewUserForm model =
    div [] <|
        List.map (\i -> viewInput (UpdateNewUserForm i.id) i) model.newUserForm
            ++ [ div [ onClick NewUser, class "important-font" ] [ text "Sign in" ]
               , div [ class "row" ]
                    [ div [ class "twelve columns" ]
                        [ a [ href "#/login" ] [ text "I already have an account" ] ]
                    ]
               ]


viewResetPwdForm : LoginModel -> Html Msg
viewResetPwdForm model =
    div []
        [ p [] [ text "In order to reset your password, please give us your login and the email you used when you created your account. You'll recieve an email with your new password" ]
        , Html.form [] <|
            List.map (\i -> viewInput (UpdateResetPwdForm i.id) i) model.resetPwdForm
                ++ [ input
                        [ onWithOptions
                            "click"
                            { preventDefault = True
                            , stopPropagation = False
                            }
                            (Json.Decode.succeed ResetPwd)
                        , class "important-font"
                        , type_ "submit"
                        , value "Reset my password"
                        ]
                        []
                        ]
        , a [ href "#/login" ] [ text "Login page" ]
        ]
