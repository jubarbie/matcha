module Views exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Users exposing (view)
import Members exposing (view)
import User exposing (view)
import Chat exposing (view, allChatsView)
import Login exposing (view)
import Account exposing (view, viewEditAccount)
import UserModel exposing (..)

view : Model -> Html Msg
view model =
  let
    role = case model.session of
      Just s -> s.user.role
      _ -> USER
  in
  div [ class "container" ]
    [ (if (model.matchAnim /= Nothing) then 
        div [ id "match-anim" ] []
      else
        div [] [])
    , div []
       <|  case model.route of
            Connect a ->
                [ Login.view a model ]
            UsersRoute ->
                [viewMenu model.route role, Users.view model]
            UserRoute a ->
                [viewMenu model.route role, User.view model]
            ChatsRoute ->
                [viewMenu model.route role, Chat.allChatsView model]
            ChatRoute a ->
                [viewMenu model.route role, Chat.view model]
            AccountRoute ->
                [viewMenu model.route role, Account.view model]
            EditAccountRoute ->
                [viewMenu model.route role, Account.viewEditAccount model]
            Members ->
                [viewMenu model.route role, Members.view model]
            NotFoundRoute ->
                [view401]
    ]

view401 : Html msg
view401 =
    div []
        [ text "401 page non trouvée"
        , a [ href "http://localhost:3000/#/users" ] [ text "Back to homepage" ]
        ]

viewMenu : Route -> UserRole -> Html Msg
viewMenu route role =
    nav [ class "navbar" ]
    [ ul [ class "navbar-list" ]
    <| [ li [ getMenuClass UsersRoute route ] [ a [ href "http://localhost:3000/#/users" ] [ text "BROWSE" ] ]
        , li [ getMenuClass ChatsRoute route ] [ a [ href "http://localhost:3000/#/chat" ] [ text "CHAT" ] ]
        , li [ getMenuClass AccountRoute route ] [ a [ href "http://localhost:3000/#/account" ] [ text "MY ACCOUNT" ] ]
        ]
        ++
        ( if role == ADMIN then
          [ li [ getMenuClass Members route ] [ a [ href "http://localhost:3000/#/members" ] [ text "MEMBERS" ] ] ]
        else
          [] )
        ++
        [ li [ class "u-pull-right", onClick Logout ] [ text "LOGOUT"  ] ]
    ]

getMenuClass : Route -> Route -> Attribute msg
getMenuClass menuRoute currentRoute =
    if menuRoute == currentRoute then class "active" else class ""
