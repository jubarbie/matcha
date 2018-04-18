module App.User.UsersView exposing (searchView, view)

import App.AppModels exposing (..)
import App.AppUtils exposing (..)
import App.User.UserHelper exposing (..)
import App.User.UserModel exposing (..)
import App.User.UserView exposing (..)
import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Json.Decode as Decode
import List
import Models exposing (..)
import Msgs exposing (..)
import Utils exposing (..)


view : AppRoutes -> Session -> AppModel -> UsersModel -> List (Html Msg)
view route session appModel model =
    [ div []
        [ usersMenuView route session appModel model
        , viewUsers route session appModel model
        ]
    ]


notifUnlikeView : AppRoutes -> AppModel -> Html Msg
notifUnlikeView route appModel =
    if route == UsersRoute "likers" then
        div [] <| List.map (\n -> div [ class "text-warning center" ] [ text <| n ++ " unliked you" ]) appModel.notifUnlike
    else
        div [] []


searchView : AppRoutes -> Session -> AppModel -> UsersModel -> List (Html Msg)
searchView route session appModel model =
    if List.length model.users == 0 then
        [ div [ id "advance-search", class "center" ]
            [ div
                [ class <|
                    "center"
                        ++ (if appModel.showAdvanceFilters then
                                " active"
                            else
                                ""
                           )
                ]
                [ div [ class "layout-row xs-no-flex" ]
                    [ ageSearchView appModel.search
                    , locSearchView appModel.search
                    ]
                , tagsSearchView session appModel
                ]
            , button [ onClick AdvanceSearch ] [ text "Search" ]
            ]
        , div [ class "center " ] [ button [ onClick ResetSearch, class "btn-no-style" ] [ text "Reset" ] ]
        ]
    else
        [ div []
            [ div [ class "filter-menu center" ]
                [ div [ class "layout xs-no-flex" ] [ sortMenuView model ] ]
            , viewUsers route session appModel model
            ]
        ]


tagsSearchView : Session -> AppModel -> Html Msg
tagsSearchView session model =
    div [ class "center" ] <|
        List.map
            (\t ->
                let
                    me =
                        if List.member t model.search.tags then
                            " metoo"
                        else
                            ""
                in
                button [ class <| "tag" ++ me, onClick <| UpdateSearchTags t ]
                    [ text <| "#" ++ t ]
            )
            session.user.tags


ageSearchView : SearchModel -> Html Msg
ageSearchView model =
    div [ class "layout-column flex align-center" ]
        [ div [ class "layout" ]
            [ div [] [ text "From " ]
            , div []
                [ select [ onInput UpdateMinYearSearch ] <|
                    option
                        ([ value "No" ]
                            ++ (if model.yearMin == Nothing then
                                    [ Html.Attributes.attribute "selected" "selected" ]
                                else
                                    []
                               )
                        )
                        [ text "No" ]
                        :: List.map
                            (\a ->
                                option
                                    ([ value <| toString a ]
                                        ++ (if model.yearMin == Just a then
                                                [ Html.Attributes.attribute "selected" "selected" ]
                                            else
                                                []
                                           )
                                    )
                                    [ text <| toString a ]
                            )
                            (List.range 18 98)
                ]
            , div [] [ text " to " ]
            , div []
                [ select [ onInput UpdateMaxYearSearch ] <|
                    option
                        ([ value "No" ]
                            ++ (if model.yearMax == Nothing then
                                    [ Html.Attributes.attribute "selected" "selected" ]
                                else
                                    []
                               )
                        )
                        [ text "No" ]
                        :: List.map
                            (\a ->
                                option
                                    ([ value <| toString a ]
                                        ++ (if model.yearMax == Just a then
                                                [ Html.Attributes.attribute "selected" "selected" ]
                                            else
                                                []
                                           )
                                    )
                                    [ text <| toString a ]
                            )
                            (List.range 18 98)
                ]
            , div [] [ text " years old" ]
            ]
        ]


locSearchView : SearchModel -> Html Msg
locSearchView model =
    div [ class "layout-column flex align-center" ]
        [ div [ class "layout" ]
            [ div [] [ text "Less than" ]
            , select [ onInput UpdateLocSearch ] <|
                option
                    ([ value "No" ]
                        ++ (if model.loc == Nothing then
                                [ Html.Attributes.attribute "selected" "selected" ]
                            else
                                []
                           )
                    )
                    [ text "No" ]
                    :: List.map
                        (\v ->
                            option
                                ([ value <| toString v ]
                                    ++ (if model.loc == Just v then
                                            [ Html.Attributes.attribute "selected" "selected" ]
                                        else
                                            []
                                       )
                                )
                                [ text <| toString v ]
                        )
                        [ 1, 5, 10, 20, 50, 100, 200, 500 ]
            , div [] [ text " km away" ]
            ]
        ]


advanceFilterView : Session -> AppModel -> UsersModel -> Html Msg
advanceFilterView session appModel model =
    div
        [ id "advance-filters"
        , class <|
            "center"
                ++ (if appModel.showAdvanceFilters then
                        " active"
                    else
                        ""
                   )
        ]
        [ div [ class "layout-row xs-no-flex" ]
            [ ageFilterView
            , locFilterView
            ]
        , tagsFilterView session model
        , button [ onClick ResetFilters, class "btn-no-style" ] [ text "Reset" ]
        ]


locFilterView : Html Msg
locFilterView =
    div [ class "layout-column flex align-center" ]
        [ div [ class "layout" ]
            [ div [] [ text "Less than" ]
            , select [ onInput UpdateLocFilter ] <| List.map (\v -> option [ value <| toString v ] [ text <| toString v ]) [ 1, 5, 10, 20, 50, 100, 200, 500 ]
            , div [] [ text " km away" ]
            ]
        ]


sortMenuView : UsersModel -> Html Msg
sortMenuView model =
    ul [ class "group-btn" ]
        [ li [ class <| getActiveClass (S_Afin == model.userSort) ]
            [ button [ class "button", onClick <| ChangeSort S_Afin ]
                [ text <| "Affinity ", span [ class "sort-arrow" ] [ text <| sortArrow model.orderSort ] ]
            ]
        , li [ class <| getActiveClass (S_Age == model.userSort) ]
            [ button [ class "button", onClick <| ChangeSort S_Age ]
                [ text <| "Age ", span [ class "sort-arrow" ] [ text <| sortArrow model.orderSort ] ]
            ]
        , li [ class <| getActiveClass (S_Dist == model.userSort) ]
            [ button [ class "button", onClick <| ChangeSort S_Dist ]
                [ text <| "Distance ", span [ class "sort-arrow" ] [ text <| sortArrow model.orderSort ] ]
            ]
        , li [ class <| getActiveClass (S_LastOn == model.userSort) ]
            [ button [ class "button", onClick <| ChangeSort S_LastOn ]
                [ text <| "LastOn ", span [ class "sort-arrow" ] [ text <| sortArrow model.orderSort ] ]
            ]
        ]


sortArrow : OrderSort -> String
sortArrow order =
    case order of
        ASC ->
            "↑"

        DESC ->
            "↓"


usersMenuView : AppRoutes -> Session -> AppModel -> UsersModel -> Html Msg
usersMenuView route session appModel model =
    div [ class "filter-menu center" ]
        [ div [ class "layout xs-no-flex" ]
            [ userMenuView route appModel
            , sortMenuView model
            ]
        , advanceFilterView session appModel model
        ]


tagsFilterView : Session -> UsersModel -> Html Msg
tagsFilterView session model =
    div [ class "center" ] <|
        List.map
            (\t ->
                let
                    me =
                        if List.member t (getFilterTags model.userFilter) then
                            " metoo"
                        else
                            ""
                in
                button [ class <| "tag" ++ me, onClick <| UpdateTagFilter t ]
                    [ text <| "#" ++ t ]
            )
            session.user.tags


ageFilterView : Html Msg
ageFilterView =
    div [ class "layout-column flex align-center" ]
        [ div [ class "layout" ]
            [ div [] [ text "From " ]
            , div []
                [ select [ onInput UpdateMinAgeFilter ] <|
                    option [ value "No" ] [ text "No" ]
                        :: List.map (\a -> option [ value <| toString a ] [ text <| toString a ]) (List.range 18 98)
                ]
            , div [] [ text " to " ]
            , div []
                [ select [ onInput UpdateMaxAgeFilter ] <|
                    option [ value "No" ] [ text "No" ]
                        :: List.map (\a -> option [ value <| toString a ] [ text <| toString a ]) (List.range 18 98)
                ]
            , div [] [ text " years old" ]
            ]
        ]


getActiveClass : Bool -> String
getActiveClass a =
    if a then
        "active"
    else
        ""


userMenuView : AppRoutes -> AppModel -> Html Msg
userMenuView route model =
    ul [ class "group-btn" ]
        [ li [ class <| getActiveClass (route == UsersRoute "all") ]
            [ a [ class "button", href "/#/users/" ]
                [ text "Around me" ]
            ]
        , li [ class <| getActiveClass (route == UsersRoute "visitors") ]
            [ a [ class "button", href "/#/users/visitors" ]
                [ text "Visitors "
                , notif <| List.length model.notifVisit
                ]
            ]
        , li [ class <| getActiveClass (route == UsersRoute "likers") ]
            [ a [ class "button", href "/#/users/likers" ]
                [ text "Likers "
                , notif <| List.length model.notifLike + List.length model.notifUnlike
                ]
            ]
        , li [ class <| getActiveClass (route == UsersRoute "matchers") ]
            [ a [ class "button", href "/#/users/matchers" ]
                [ text "Matchers "
                ]
            ]
        ]


viewUsers : AppRoutes -> Session -> AppModel -> UsersModel -> Html Msg
viewUsers route session appModel model =
    let
        view =
            if List.length model.users == 0 then
                emptyUsersView
            else
                viewUsersList route session appModel model
    in
    div [ id "users-list", class "layout-column" ]
        [ if getAccountNotif session.user > 0 then
            div [ onClick ToggleAccountMenu, class "text-warning pointer center" ] [ text "Please complete your account to be able to interract with users" ]
          else
            div [] []
        , notifUnlikeView route appModel
        , view
        ]


emptyUsersView : Html Msg
emptyUsersView =
    div [ class "layout-column flex center" ] [ text "No users" ]


viewUsersList : AppRoutes -> Session -> AppModel -> UsersModel -> Html Msg
viewUsersList route session appModel model =
    let
        listF =
            List.filter (filterUser model.userFilter) model.users

        list =
            case model.userSort of
                S_Dist ->
                    List.sortBy .distance listF

                S_Age ->
                    List.reverse <| List.sortBy .date_of_birth listF

                S_LastOn ->
                    List.reverse <| List.sortBy .lastOn listF

                S_Afin ->
                    List.reverse <| List.sortBy (\u -> getAffinityScore session.user u) listF

        listOrdered =
            if model.orderSort == DESC then
                List.reverse list |> List.indexedMap (,)
            else
                list |> List.indexedMap (,)
    in
    Html.Keyed.node "ul" [ class <| "users-list" ] <|
        List.map
            (\( i, u ) ->
                ( u.username, li [] [ cardUserView route appModel u i session model ] )
            )
        <|
            listOrdered


cardUserView : AppRoutes -> AppModel -> User -> Int -> Session -> UsersModel -> Html Msg
cardUserView route appModel user i session model =
    let
        clss =
            "user-card animated fadeInUp"
                ++ (case route of
                        UsersRoute "likers" ->
                            if List.member user.username appModel.notifLike then
                                " new-card"
                            else
                                ""

                        UsersRoute "visitors" ->
                            if List.member user.username appModel.notifVisit then
                                " new-card"
                            else
                                ""

                        _ ->
                            ""
                   )
    in
    div [ onClick <| ShowUser user.username, class clss, style [ ( "animation-delay", toString (toFloat i / 15) ++ "s" ), ( "animation-duration", ".3s" ) ] ]
        [ userImageView user session model
        , userInfosView appModel user model
        ]


userInfosView : AppModel -> User -> UsersModel -> Html Msg
userInfosView appModel user model =
    div [ class "user-infos" ] <|
        [ userNameView user
        , userDistanceView user
        ]
            ++ (if getOnlineStatus appModel user then
                    [ div [ class "online-status on" ] [ text "Online ", Html.Keyed.node "online" [ class "fas fa-circle" ] [] ] ]
                else
                    []
               )


isMainImage : ( Int, String, Bool ) -> Bool
isMainImage ( a, b, c ) =
    c


userImageView : User -> Session -> UsersModel -> Html Msg
userImageView user session model =
    let
        imgSrc =
            case List.head <| List.filter isMainImage user.photos of
                Just ( id_, src, main ) ->
                    src

                _ ->
                    "http://profile.actionsprout.com/default.jpeg"
    in
    div [ style [ ( "background", "url(" ++ imgSrc ++ ") center center no-repeat" ) ], class "img-box" ]
        []
