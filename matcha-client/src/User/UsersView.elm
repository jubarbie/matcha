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
import Json.Decode as Decode


view : Model -> List (Html Msg)
view model =
    case model.session of
        Just s ->
            [ div []
                [ sortMenuView model s
                , viewUsers model s
                , advanceFilterView model s
                ]
            ]

        _ ->
            []

advanceFilterView : Model -> Session -> Html Msg
advanceFilterView model s =
  div [ id "advance-filters", class <| if model.showAdvanceFilters then "active" else "" ]
      [ tagsFilterView model s
      , ageFilterView
      , locFilterView
      , button [ onClick ResetFilters ] [ text "Reset" ]
      ]

locFilterView : Html Msg
locFilterView =
  div []
      [ h3 [] [ text "By distance (km)"]
      , input [ onInput UpdateLocFilter ] []
      ]

sortMenuView : Model -> Session -> Html Msg
sortMenuView model s =
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

tagsFilterView : Model -> Session -> Html Msg
tagsFilterView model s =
  div []
    <| h3 [] [ text "By tags" ]
      ::
      List.map (\t ->
        let
            me =
                if List.member t (getFilterTags model.userFilter) then
                    " metoo"
                else
                    ""
        in
      button [ class <| "tag" ++ me, onClick <| UpdateTagFilter t ]
        [ text <| "#" ++ t ]
      ) s.user.tags

ageFilterView : Html Msg
ageFilterView =
  div []
      [ h3 [] [ text "By age range"]
      , div [ class "layout" ]
            [ div []
                  [ label [ for "min" ] [ text "Min" ]
                  , select [ onInput UpdateMinAgeFilter ]
                    <| option [ value "No"] [ text "No" ] :: List.map (\a -> option [ value <| toString a ] [ text <| toString a ] ) (List.range 18 98)
                  ]

            , div []
                  [ label [ for "max" ] [ text "Max" ]
                  , select [ onInput UpdateMaxAgeFilter ]
                    <| option [ value "No"] [ text "No" ] :: List.map (\a -> option [ value <| toString a ] [ text <| toString a ] ) (List.range 18 98)
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
        , li []
            [ button [ class "btn-no-style", onClick ToggleAdvanceFilters ] [ text "..." ]
            ]
        ]


viewUsers : Model -> Session -> Html Msg
viewUsers model s =
    let
        listF =
          List.filter (filterUser model.userFilter) model.users

        list =
            case model.userSort of
                S_Dist ->
                    List.sortBy .distance listF

                S_Age ->
                    List.sortBy .date_of_birth listF

                S_LastOn ->
                    List.sortBy .lastOn listF

                S_Afin ->
                    List.sortBy (\u -> getAffinityScore s.user u) listF

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
