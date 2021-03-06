module Login.LoginView exposing (view)

import FormUtils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed exposing (..)
import Json.Decode
import Login.LoginModels exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Utils exposing (..)


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
    div [ class "layout-column center container" ]
        [ img [ src "http://localhost:3001/images/DARKROOM_logo.svg", alt "DARKROOM" ] []
        , case model.message of
            Just m ->
                div [] [ text m ]

            _ ->
                div [] []
        , view
        ]


view404 : Html Msg
view404 =
    div [] [ text "404 not found" ]


viewLoginForm : LoginModel -> Html Msg
viewLoginForm model =
    Html.form [ class "home-form" ] <|
        List.map (\i -> viewInput (UpdateLoginForm i.id) i) model.loginForm
            ++ [ input
                    [ onClickCustom True False SendLogin
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
    Html.form [ class "home-form" ] <|
        List.map (\i -> viewInput (UpdateNewUserForm i.id) i) model.newUserForm
            ++ [ input
                    [ onClickCustom True False NewUser
                    , class "important-font"
                    , type_ "submit"
                    , value "SIGN IN"
                    ]
                    []
               , div [ class "row" ]
                    [ div [ class "twelve columns" ]
                        [ a [ href "#/login" ] [ text "I already have an account" ] ]
                    ]
               ]


viewResetPwdForm : LoginModel -> Html Msg
viewResetPwdForm model =
    div []
        [ p [] [ p [] [ text "In order to reset your password, please enter your login and email." ], p [] [ text "You'll recieve an email with your new password" ] ]
        , Html.form [ class "home-form" ] <|
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
