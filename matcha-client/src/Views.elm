module Views exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Users exposing (view)
import AdminUsers exposing (view)
import User exposing (view)
import Chat exposing (view, allChatsView)
import Login exposing (view)
import Account exposing (view, viewEditAccount)
import UserModel exposing (..)

view : Model -> Html Msg
view model =
  case model.session of
      Just s ->
        div [ class "container" ]
          [ (if (model.matchAnim /= Nothing) then
              div [ id "match-anim" ] []
            else
              div [] [])
          , (case model.message of
              Just msg ->
                div [ class "alert" ] [ text msg ]
              Nothing ->
                div [][]
            )
          , div []
             <|  case model.route of
                  Connect a ->
                      [ Login.view a model ]
                  UsersRoute ->
                      [viewMenu model.route s, Users.view model]
                  UserRoute a ->
                      [viewMenu model.route s, User.view model]
                  ChatsRoute ->
                      [viewMenu model.route s, Chat.allChatsView model]
                  ChatRoute a ->
                      [viewMenu model.route s, Chat.view model]
                  AccountRoute ->
                      [viewMenu model.route s, Account.view model]
                  EditAccountRoute ->
                      [viewMenu model.route s, Account.viewEditAccount model]
                  ChangePwdRoute ->
                      [viewMenu model.route s, Account.viewChangePwd model]
                  Members ->
                      [viewMenu model.route s, AdminUsers.view model]
                  NotFoundRoute ->
                      [view401]
          ]
      _ -> div [][]

view401 : Html msg
view401 =
    div []
        [ text "401 page non trouvée"
        , a [ href "http://localhost:3000/#/users" ] [ text "Back to homepage" ]
        ]

viewMenu : Route -> Session -> Html Msg
viewMenu route session =
    nav [ class "navbar" ]
    [ ul [ class "navbar-list" ]
    <| [ li [ getMenuClass UsersRoute route ] [ a [ href "http://localhost:3000/#/users" ] [ text "BROWSE" ] ]
        , li [ getMenuClass ChatsRoute route ] [ a [ href "http://localhost:3000/#/chat" ] [ text "CHAT" ] ]
        ]
        ++
        ( if session.user.role == ADMIN then
          [ li [ getMenuClass Members route ] [ a [ href "http://localhost:3000/#/members" ] [ text "MEMBERS" ] ]
          ]
        else
          [] )
        ++
        [ div [ class "u-pull-right" ]
              [ li [ getMenuClass AccountRoute route] [ a [ href "http://localhost:3000/#/account" ] [ text "MY ACCOUNT" ] ]
              , li [ onClick Logout ] [ text "LOGOUT"  ]
              ]
        ]
    ]

getMenuClass : Route -> Route -> Attribute msg
getMenuClass menuRoute currentRoute =
    if menuRoute == currentRoute then class "active" else class ""
