module User.UsersView exposing (view)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import List
import Models exposing (..)
import Msgs exposing (..)
import User.UserHelper exposing (..)
import User.UserModel exposing (..)
import User.UserView exposing (..)
import Utils exposing (..)


view : Model -> List (Html Msg)
view model =
    case model.session of
        Just s ->
            [ div []
                [ sortMenuView model
                , viewUsers model s
                ]
            ]

        _ ->
            []


sortMenuView : Model -> Html Msg
sortMenuView model =
    div [ class "filter-menu center" ]
        [ userMenuView model
        , ul [ class "group-btn" ]
            [ li [ class <| getActiveClass (S_Afin == model.userSort) ]
                [ button [ class "button", onClick <| ChangeSort S_Afin ]
                    [ text "Affinity" ]
                ]
            , li [ class <| getActiveClass (S_Age == model.userSort) ]
                [ button [ class "button", onClick <| ChangeSort S_Age ]
                    [ text "Age" ]
                ]
            , li [ class <| getActiveClass (S_Dist == model.userSort) ]
                [ button [ class "button", onClick <| ChangeSort S_Dist ]
                    [ text "Distance" ]
                ]
            , li [ class <| getActiveClass (S_LastOn == model.userSort) ]
                [ button [ class "button", onClick <| ChangeSort S_LastOn ]
                    [ text "LastOn" ]
                ]
            ]
        ]


getActiveClass : Bool -> String
getActiveClass a =
    if a then
        "active"
    else
        ""


userMenuView : Model -> Html Msg
userMenuView model =
    ul [ class "group-btn" ]
        [ li [ class <| getActiveClass (model.route == UsersRoute "all") ]
            [ a [ class "button", href "http://localhost:3000/#/users/" ]
                [ text "Around me" ]
            ]
        , li [ class <| getActiveClass (model.route == UsersRoute "visitors") ]
            [ a [ class "button", href "http://localhost:3000/#/users/visitors" ]
                [ text "Visitors "
                , notif model.notifVisit
                ]
            ]
        , li [ class <| getActiveClass (model.route == UsersRoute "likers") ]
            [ a [ class "button", href "http://localhost:3000/#/users/likers" ]
                [ text "Likers "
                , notif model.notifLike
                ]
            ]
        ]


viewUsers : Model -> Session -> Html Msg
viewUsers model s =
    let
        list =
            case model.userSort of
                S_Dist ->
                    List.sortBy .distance model.users

                S_Age ->
                    List.sortBy .date_of_birth model.users

                S_LastOn ->
                    List.sortBy .lastOn model.users

                S_Afin ->
                    List.sortBy (\u -> getAffinityScore s.user u) model.users

        listOrdered =
            if model.orderSort == DESC then
                List.reverse list
            else
                list
    in
    div []
        [ ul [ class <| "users-list" ] <|
            List.map
                (\u ->
                    li [] [ cardUserView u model s ]
                )
            <|
                listOrdered
        ]


cardUserView : User -> Model -> Session -> Html Msg
cardUserView user model s =
    Html.Keyed.node (String.filter Char.isLower user.username)
        []
        [ ( "div"
          , div [ class "user-box" ]
                [ userImageView user model
                , userInfosView user model s
                , a [ href <| "http://localhost:3000/#/user/" ++ user.username, class "user-link" ] []
                ]
          )
        ]


userInfosView : User -> Model -> Session -> Html Msg
userInfosView user model s =
    div [ class "user-infos" ]
        [ userNameView user

        -- , div [] [ getAffinityScore s.user user |> toString |> text ]
        , userDistanceView user
        ]


userImageView : User -> Model -> Html Msg
userImageView user model =
    let
        imgSrc =
            case List.head user.photos of
                Just src ->
                    src

                _ ->
                    "http://profile.actionsprout.com/default.jpeg"
    in
    case model.session of
        Just s ->
            div [ style [ ( "background", "url(" ++ imgSrc ++ ") center center no-repeat" ) ], class "img-box" ]
                [ div [ class "user-menu" ]
                    [ userLikeButtonView s user ]
                ]

        _ ->
            div [] []
