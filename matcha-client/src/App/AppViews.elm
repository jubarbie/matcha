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


view : AppRoutes -> Session -> AppModel -> UsersModel -> TalksModel -> Html Msg
view route session appModel usersModel talksModel =
  let
    viewToShow =
      case route of
        UsersRoute a ->
            []

        UserRoute a ->
            App.User.UserView.view a session appModel usersModel

        AccountRoute ->
            [ App.User.UserAccountView.view session appModel ]

        EditAccountRoute ->
            [ App.User.UserAccountView.viewEditAccount session appModel ]

        ChangePwdRoute ->
            [ App.User.UserAccountView.viewChangePwd appModel ]

        NotFoundAppRoute ->
            [ view404 ]
  in
    div [ class "layout-row"]
        <|
        [ div [ class <| "container" ++ if viewToShow == [] then "" else " blur" ] <| viewMenu route session appModel talksModel :: App.User.UsersView.view route session appModel usersModel
        , alertMessageView appModel
        ] ++ viewToShow

alertMessageView : AppModel -> Html Msg
alertMessageView model =
  case model.message of
          Just msg ->
              div [ class "alert" ] [ text msg ]

          Nothing ->
              div [] []

view404 : Html msg
view404 =
    div []
        [ text "404 error, page not found"
        , a [ href "http://localhost:3000/#/users" ] [ text "Back to homepage" ]
        ]


viewMenu : AppRoutes -> Session -> AppModel -> TalksModel -> Html Msg
viewMenu route session appModel talksModel =
  div []
    <| [ nav [ class "navbar" ]
            [ ul [ class "navbar-list" ] <|
                [ ul []
                    [ li [ getMenuClass (UsersRoute "all") route ] [ a [ href "http://localhost:3000/#/users/all" ] [ icon "fas fa-th" ] ]
                    , li [  ]
                        [ a [  ]
                            [ icon "fas fa-comments"
                            , notif <| App.Talk.TalkUtils.getTalkNotif talksModel.talks
                            ]
                        ]
                    ]
                , viewAccountMenu appModel
                ]
            ]
      ] ++ viewAccountBox session appModel ++ [ div [] [ talksListView talksModel ] ]

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
