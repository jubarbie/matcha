module App.AppViews exposing (view)

import App.AppModels exposing (..)
import App.Talk.TalkModel exposing (..)
import App.Talk.TalkUtils exposing (..)
import App.Talk.TalkView exposing (..)
import App.User.UserAccountView exposing (..)
import App.User.UserModel exposing (..)
import App.User.UserView exposing (view)
import App.User.UsersView exposing (searchView, view)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed exposing (..)
import Json.Decode
import Login.LoginView exposing (view)
import Models exposing (..)
import Msgs exposing (..)
import Utils exposing (..)


view : AppRoutes -> Session -> AppModel -> UsersModel -> TalksModel -> Html Msg
view route session appModel usersModel talksModel =
    let
        view =
            case route of
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

        onTop =
            appModel.showTalksList || appModel.showAccountMenu || usersModel.currentUser /= Nothing
    in
    div [ class "layout-row" ] <|
        [ div
            [ class <|
                "container"
                    ++ (if onTop then
                            " blur"
                        else
                            ""
                       )
            ]
            [ alertMessageView appModel
            , viewCurrentTalk appModel talksModel
            , view
            ]
        ]
            ++ (if onTop then
                    [ div [ class "on-top", onClickCustom False True UnshowAll ] []
                    , div [] <|
                        (case ( usersModel.currentUser, appModel.showAccountMenu, appModel.showTalksList ) of
                            ( Just username, False, False ) ->
                                [ App.User.UserView.view username session appModel usersModel ]

                            _ ->
                                []
                        )
                            ++ (if appModel.showAccountMenu then
                                    [ div [ class "animated fadeInLeft", id "account-menu" ] <|
                                        viewAccountBox
                                            session
                                            appModel
                                    ]
                                else
                                    []
                               )
                            ++ (if appModel.showTalksList then
                                    [ div [ class "animated fadeInLeft", id "talks-list" ]
                                        [ talksListView talksModel ]
                                    ]
                                else
                                    []
                               )
                    ]
                else
                    []
               )
            ++ [ viewMenu route session appModel talksModel ]


viewCurrentTalk : AppModel -> TalksModel -> Html Msg
viewCurrentTalk appModel model =
    case model.currentTalk of
        Nothing ->
            div [] []

        Just talk ->
            div [] <| App.Talk.TalkView.view talk appModel model


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
    div [] <|
        [ nav [ class "navbar" ]
            [ Html.ul [ class "navbar-list" ] <|
                [ Html.ul []
                    [ li [ getMenuClass (UsersRoute "all") route ] [ a [ href "http://localhost:3000/#/users/all" ] [ icon "fas fa-th" ] ]
                    , li [ getMenuClass SearchRoute route ] [ button [ onClick ResetSearch ] [ icon "fas fa-search" ] ]
                    , li [ class "notif-menu" ]
                        [ button [ onClick ToggleTalksList ]
                            [ icon "fas fa-comments" ]
                        , notif <| App.Talk.TalkUtils.getTalkNotif talksModel.talks
                        ]
                    ]
                , li [] [ button [ onClick ToggleAccountMenu ] [ icon "fas fa-user" ] ]
                ]
            ]
        ]


viewAccountBox : Session -> AppModel -> List (Html Msg)
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
        [ div [ style [ ( "width", "100%" ) ] ]
            [ div [ class "layout-padding" ]
                [ h2 [] [ text session.user.username ]
                , div [] [ text <| session.user.fname ++ " " ++ session.user.lname ]
                , div [] [ text session.user.email ]
                , div [] [ text shortBio ]
                , div [] [ a [ href "http://localhost:3000/#/edit_account" ] [ text "Edit infos" ] ]
                , div [] [ a [ href "http://localhost:3000/#/edit_password" ] [ text "Edit password" ] ]
                ]
            , div [ class "layout-padding center" ] [ viewTagSection model session.user ]
            , div [ class "layout-padding center" ] [ viewDateOfBirthInput session.user ]
            , div [ class "layout-padding center" ] [ viewGenderForm session.user.gender ]
            , div [ class "layout-padding center" ] [ viewIntInForm session.user.intIn ]
            , div [] [ viewImages model session.user ]
            , div [ onClick Logout, class "center logout-btn" ] [ text "Logout ", icon "fas fa-power-off" ]
            ]
        ]
    else
        []


getMenuClass : AppRoutes -> AppRoutes -> Attribute msg
getMenuClass menuRoute currentRoute =
    if menuRoute == currentRoute then
        class "active"
    else
        case ( menuRoute, currentRoute ) of
            ( UsersRoute _, UsersRoute _ ) ->
                class "active"

            _ ->
                class ""
