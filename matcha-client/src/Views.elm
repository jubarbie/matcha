module Views exposing (view)

import Account exposing (view, viewEditAccount)
import AdminUsers exposing (view)
import Chat exposing (allChatsView, view)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Login exposing (view)
import Models exposing (..)
import Msgs exposing (..)
import User exposing (view)
import UserModel exposing (..)
import Users exposing (view)


view : Model -> Html Msg
view model =
    div [ class "container" ]
        <| (if model.matchAnim /= Nothing then
            [ div [ id "match-anim" ] [] ]
          else
            [])
        ++ (case model.message of
            Just msg ->
              [ div [ class "alert" ] [ text msg ] ]
            Nothing ->
              [])
        ++ (case ( model.route, model.session ) of
                ( Connect a, _ ) ->
                    [ Login.view a model ]

                ( UsersRoute a, Just s ) ->
                    [ viewMenu model.route s, Users.view model ]

                ( UserRoute a, Just s ) ->
                    [ viewMenu model.route s, User.view model ]

                ( ChatsRoute, Just s ) ->
                    [ viewMenu model.route s, Chat.allChatsView model ]

                ( ChatRoute a, Just s ) ->
                    [ viewMenu model.route s ] ++  Chat.view model

                ( AccountRoute, Just s ) ->
                    [ viewMenu model.route s, Account.view model ]

                ( EditAccountRoute, Just s ) ->
                    [ viewMenu model.route s, Account.viewEditAccount model ]

                ( ChangePwdRoute, Just s ) ->
                    [ viewMenu model.route s, Account.viewChangePwd model ]

                _ ->
                    [ view401 ])


view401 : Html msg
view401 =
    div []
        [ text "401 page non trouvée"
        , a [ href "http://localhost:3000/#/users" ] [ text "Back to homepage" ]
        ]


viewMenu : Route -> Session -> Html Msg
viewMenu route session =
    nav [ class "navbar" ]
        [ ul [ class "navbar-list" ] <|
            [ li [ getMenuClass (UsersRoute "all") route ] [ a [ href "http://localhost:3000/#/users/all" ] [ text "BROWSE" ] ]
            , li [ getMenuClass ChatsRoute route ]
              [ a [ href "http://localhost:3000/#/chat" ]
                [ text "CHAT"
                , span [ class "notif" ] [ text <| getChatNotif session.user.talks ] 
                ]
              ]
            , div [ class "u-pull-right" ]
                [ li [ getMenuClass AccountRoute route ] [ a [ href "http://localhost:3000/#/account" ] [ text "MY ACCOUNT" ] ]
                , li [ onClick Logout ] [ text "LOGOUT" ]
                ]
            ]
        ]

getChatNotif : List Talk -> String
getChatNotif talks =
  toString <| List.sum <| List.map .unreadMsgs talks

getMenuClass : Route -> Route -> Attribute msg
getMenuClass menuRoute currentRoute =
    if menuRoute == currentRoute then
        class "active"
    else
        class ""
