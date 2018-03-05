module App.AppViews exposing (view)

import App.User.UserAccountView exposing (view, viewEditAccount)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed exposing (..)
import Html.Events exposing (..)
import App.AppModels exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import App.User.UserModel exposing (..)
import App.User.UsersView exposing (view, searchView)
import App.User.UserView exposing (view)
import Login.LoginView exposing (view)
import Utils exposing (..)
import App.Talk.TalkModel exposing (..)
import App.Talk.TalkUtils exposing (..)
import App.Talk.TalkView exposing (..)


view : AppRoutes -> Session -> AppModel -> UsersModel -> TalksModel -> Html Msg
view route session appModel usersModel talksModel =
  let
    view =
      case route of
        UserRoute a ->
          div [] <| App.User.UsersView.view route session appModel usersModel

        UsersRoute a ->
          div [] <| App.User.UsersView.view route session appModel usersModel

        SearchRoute ->
          div [] <| App.User.UsersView.searchView route session appModel usersModel

        AccountRoute ->
          App.User.UserAccountView.view session appModel

        EditAccountRoute ->
          App.User.UserAccountView.viewEditAccount session appModel

        ChangePwdRoute ->
          App.User.UserAccountView.viewChangePwd appModel

        NotFoundAppRoute ->
          view404
  in
    div [ class "layout-row" ] <|
        [ div [ class <| "container" ++ (case route of
          UserRoute a -> " blur"
          _ -> ""
        ) ++ (if appModel.showTalksList then " talks-expand" else "") ++ (if appModel.showAccountMenu then " account-expand" else "")]
          [ alertMessageView appModel
          , viewMenu route session appModel talksModel
          , viewCurrentTalk appModel talksModel
          , div [ id "talks-list" ] [ talksListView talksModel ]
          , div [ id "account-menu" ] <| viewAccountBox session appModel
          , view
          ]
        ]
        ++
          (case route of
            UserRoute a -> App.User.UserView.view a session appModel usersModel
            _ -> []
          )


viewCurrentTalk : AppModel -> TalksModel -> Html Msg
viewCurrentTalk appModel model =
  case model.currentTalk of
    Nothing -> div [] []
    Just talk -> div [] <| App.Talk.TalkView.view talk appModel model

alertMessageView : AppModel -> Html Msg
alertMessageView model =
  case model.message of
          Just msg ->
              div [ class "alert alert-danger" ] [ text msg ]

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
            [ Html.ul [ class "navbar-list" ] <|
                [ Html.ul []
                    [ li [ getMenuClass (UsersRoute "all") route ] [ a [ href "http://localhost:3000/#/users/all" ] [ icon "fas fa-th" ] ]
                    , li [ getMenuClass SearchRoute route ] [ a [ href "http://localhost:3000/#/search" ] [ icon "fas fa-search" ] ]
                    , li [ class "notif-menu" ]
                        [ button [ onClick ToggleTalksList ]
                            [ icon "fas fa-comments" ]
                        , notif <| App.Talk.TalkUtils.getTalkNotif talksModel.talks
                        ]
                    ]
                , li [ ] [ button [ onClick ToggleAccountMenu ] [ icon "fas fa-user" ] ]
                ]
            ]
      ]


viewAccountBox :  Session -> AppModel -> List (Html Msg)
viewAccountBox session model =
  let
    shortBio =
      if String.length session.user.bio == 0 then
        "No bio"
      else if String.length session.user.bio < 50 then
        session.user.bio
      else
        String.left 50 session.user.bio ++ "..."
  in
    if model.showAccountMenu then
      [ div [ ]
          [ div [ class "layout-padding" ]
                [ div [] [ text session.user.username ]
                , div [] [ text shortBio ]
                ]
          , div [ class "layout"]
                [ div [ class "flex edit-btn" ] [ a [ href "http://localhost:3000/#/account" ] [ text "Edit" ] ]
                , div [ onClick Logout, id "logout-btn" ] [ icon "fas fa-power-off" ]
                ]
          ]
      ]
    else []

getMenuClass : AppRoutes -> AppRoutes -> Attribute msg
getMenuClass menuRoute currentRoute =
    if menuRoute == currentRoute then
        class "active"
    else
      case (menuRoute, currentRoute) of
        (UsersRoute _, UsersRoute _) -> class "active"
        _ -> class ""
