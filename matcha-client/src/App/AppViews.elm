module App.AppViews exposing (view)

import App.User.UserAccountView exposing (view, viewEditAccount)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import App.AppModels exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import App.User.UserModel exposing (..)
import App.User.UsersView exposing (view)
import App.User.UserView exposing (view)
import Login.LoginView exposing (view)
import Utils exposing (..)
import App.Talk.TalkModel exposing (..)
import App.Talk.TalkUtils exposing (..)
import App.Talk.TalkView exposing (..)


view : AppRoutes -> Session -> AppModel -> Html Msg
view route session model =
    div [ class "container" ] <|
        (if model.matchAnim /= Nothing then
            [ div [ id "match-anim" ] [] ]
         else
            []
        )
            ++ (case model.message of
                    Just msg ->
                        [ div [ class "alert" ] [ text msg ] ]

                    Nothing ->
                        []
               )
            ++ (case route of
                    UsersRoute a ->
                        [ viewMenu route session model ] ++ (App.User.UsersView.view route session model)

                    UserRoute a ->
                        [ div [ class "blur" ] <| [ viewMenu route session model ] ++ (App.User.UsersView.view route session model) ] ++ (App.User.UserView.view a session model)

                    TalksRoute ->
                        [ viewMenu route session model, App.Talk.TalkView.talksListView route model ]

                    TalkRoute a ->
                        [ viewMenu route session model ] ++ App.Talk.TalkView.view a route model

                    AccountRoute ->
                        [ viewMenu route session model, App.User.UserAccountView.view session model ]

                    EditAccountRoute ->
                        [ viewMenu route session model, App.User.UserAccountView.viewEditAccount session model ]

                    ChangePwdRoute ->
                        [ viewMenu route session model, App.User.UserAccountView.viewChangePwd model ]

                    _ ->
                        [ view404 ]
               )

view404 : Html msg
view404 =
    div []
        [ text "404 error, page not found"
        , a [ href "http://localhost:3000/#/users" ] [ text "Back to homepage" ]
        ]


viewMenu : AppRoutes -> Session -> AppModel -> Html Msg
viewMenu route session model =
  div []
    <| [ nav [ class "navbar" ]
            [ ul [ class "navbar-list" ] <|
                [ ul []
                    [ li [ getMenuClass (UsersRoute "all") route ] [ a [ href "http://localhost:3000/#/users/all" ] [ icon "fas fa-th" ] ]
                    , li [ getMenuClass TalksRoute route ]
                        [ a [ href "http://localhost:3000/#/chat" ]
                            [ icon "fas fa-comments"
                            , notif <| App.Talk.TalkUtils.getTalkNotif model.talks
                            ]
                        ]
                    ]
                , viewAccountMenu model
                ]
            ]
      ] ++ viewAccountBox session model

viewAccountMenu : AppModel -> Html Msg
viewAccountMenu model =
      li [ onClick ToggleAccountMenu ] [ a [] [ icon "fas fa-user" ] ]


viewAccountBox :  Session -> AppModel -> List (Html Msg)
viewAccountBox session model =
  if model.showAccountMenu then
    [ div [ class "account-menu" ]
        [ div [] [ text session.user.username ]
        , div [ onClick ToggleAccountMenu ] [ icon "far fa-times-circle" ]
        , div [ onClick Logout ] [ icon "fas fa-power-off" ]
        , div [ ] [ a [ href "http://localhost:3000/#/account" ] [ text "Edit" ] ]
        ]
    ]
  else []

getMenuClass : AppRoutes -> AppRoutes -> Attribute msg
getMenuClass menuRoute currentRoute =
    if menuRoute == currentRoute then
        class "active"
    else
        class ""
