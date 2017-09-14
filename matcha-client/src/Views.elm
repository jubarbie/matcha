module Views exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Members exposing (view)
import Chat exposing (view)
import Login exposing (view)
import Account exposing (view)

view : Model -> Html Msg
view model =
    div [ class "container" ]
       <|  case model.route of
            Connect a ->
                [ Login.view a model ]
            Members ->
                [viewMenu model.route, Members.view model]
            Chat ->
                [viewMenu model.route, Chat.view model]
            Account ->
                [viewMenu model.route, Account.view model]
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
        [ li [ getMenuClass Members route ] [ a [ href "http://localhost:3000/#/users" ] [ text "PARCOURIR" ] ]
        , li [ getMenuClass Chat route ] [ a [ href "http://localhost:3000/#/chat" ] [ text "CHAT" ] ]
        , li [ getMenuClass Account route ] [ a [ href "http://localhost:3000/#/account" ] [ text "MON COMPTE" ] ]
        , li [ class "pull-right", onClick Logout ] [ text "LOGOUT"  ]
        ]
    ]

getMenuClass : Route -> Route -> Attribute msg
getMenuClass menuRoute currentRoute =
    if menuRoute == currentRoute then class "active" else class ""
