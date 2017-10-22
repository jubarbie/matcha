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
import Account exposing (view)

view : Model -> Html Msg
view model =
  div [ class "container" ]
       <|  case model.route of
            Connect a ->
                [ Login.view a model ]
            UsersRoute ->
                [viewMenu model.route, Users.view model]
            UserRoute a ->
                [viewMenu model.route, User.view model]
            ChatsRoute ->
                [viewMenu model.route, Chat.allChatsView model]
            ChatRoute a ->
                [viewMenu model.route, Chat.view model]
            Account ->
                [viewMenu model.route, Account.view model]
            Members ->
                [viewMenu model.route, Members.view model]
            NotFoundRoute ->
                [view401]

view401 : Html msg
view401 =
    div []
        [ text "401 page non trouvée"
        , a [ href "http://localhost:3000/#/users" ] [ text "Retourner a l'accueil" ]
        ]

viewMenu : Route -> Html Msg
viewMenu route =
    nav [ class "navbar" ]
    [ ul [ class "navbar-list" ]
        [ li [ getMenuClass UsersRoute route ] [ a [ href "http://localhost:3000/#/users" ] [ text "PARCOURIR" ] ]
        , li [ getMenuClass ChatsRoute route ] [ a [ href "http://localhost:3000/#/chat" ] [ text "CHAT" ] ]
        , li [ getMenuClass Account route ] [ a [ href "http://localhost:3000/#/account" ] [ text "MON COMPTE" ] ]
        , li [ getMenuClass Members route ] [ a [ href "http://localhost:3000/#/members" ] [ text "LES MEMBRES" ] ]
        , li [ class "u-pull-right", onClick Logout ] [ text "LOGOUT"  ]
        ]
    ]

getMenuClass : Route -> Route -> Attribute msg
getMenuClass menuRoute currentRoute =
    if menuRoute == currentRoute then class "active" else class ""
