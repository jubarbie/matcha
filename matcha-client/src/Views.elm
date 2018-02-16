module Views exposing (view)

import User.UserAccountView exposing (view, viewEditAccount)
import Talk.TalkView exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Login exposing (view)
import Models exposing (..)
import Msgs exposing (..)
import User.UserModel exposing (..)
import User.UsersView exposing (view)
import User.UserView exposing (view)
import Utils exposing (..)
import Talk.TalkModel exposing (..)
import Talk.TalkUtils exposing (..)


view : Model -> Html Msg
view model =
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
            ++ (case ( model.route, model.session ) of
                    ( Connect a, _ ) ->
                        [ Login.view a model ]

                    ( UsersRoute a, Just s ) ->
                        [ viewMenu model s ] ++ (User.UsersView.view model)

                    ( UserRoute a, Just s ) ->
                        [ div [ class "blur" ] <| [ viewMenu model s ] ++ (User.UsersView.view model) ] ++ (User.UserView.view a model)

                    ( TalksRoute, Just s ) ->
                        [ viewMenu model s, Talk.TalkView.talksListView model ]

                    ( TalkRoute a, Just s ) ->
                        [ viewMenu model s ] ++ Talk.TalkView.view a model

                    ( AccountRoute, Just s ) ->
                        [ viewMenu model s, User.UserAccountView.view model ]

                    ( EditAccountRoute, Just s ) ->
                        [ viewMenu model s, User.UserAccountView.viewEditAccount model ]

                    ( ChangePwdRoute, Just s ) ->
                        [ viewMenu model s, User.UserAccountView.viewChangePwd model ]

                    _ ->
                        [ view401 ]
               )


view401 : Html msg
view401 =
    div []
        [ text "401 page non trouvée"
        , a [ href "http://localhost:3000/#/users" ] [ text "Back to homepage" ]
        ]


viewMenu : Model -> Session -> Html Msg
viewMenu model session =
  div []
    <| [ nav [ class "navbar" ]
            [ ul [ class "navbar-list" ] <|
                [ ul []
                    [ li [ getMenuClass (UsersRoute "all") model.route ] [ a [ href "http://localhost:3000/#/users/all" ] [ icon "fas fa-th" ] ]
                    , li [ getMenuClass TalksRoute model.route ]
                        [ a [ href "http://localhost:3000/#/chat" ]
                            [ icon "fas fa-comments"
                            , notif <| Talk.TalkUtils.getTalkNotif model.talks
                            ]
                        ]
                    ]
                , viewAccountMenu model
                ]
            ]
      ] ++ viewAccountBox model session

viewAccountMenu : Model -> Html Msg
viewAccountMenu model =
      li [ onClick ToggleAccountMenu ] [ a [] [ icon "fas fa-user" ] ]


viewAccountBox : Model -> Session -> List (Html Msg)
viewAccountBox model s =
  if model.showAccountMenu then
    [ div [ class "account-menu" ]
        [ div [] [ text s.user.username ]
        , div [ onClick ToggleAccountMenu ] [ icon "far fa-times-circle" ]
        , div [ onClick Logout ] [ icon "fas fa-power-off" ]
        , div [ ] [ a [ href "http://localhost:3000/#/account" ] [ text "Edit" ] ]
        ]
    ]
  else []

getMenuClass : Route -> Route -> Attribute msg
getMenuClass menuRoute currentRoute =
    if menuRoute == currentRoute then
        class "active"
    else
        class ""
