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


view : AppRoutes -> Session -> AppModel -> List (Html Msg)
view route session model =
    [ div []
          [ sortMenuView route session model
          , viewUsers session model
          , advanceFilterView session model
          ]
      ]

advanceFilterView : Session -> AppModel -> Html Msg
advanceFilterView session model =
  div [ id "advance-filters", class <| if model.showAdvanceFilters then "active" else "" ]
      [ tagsFilterView session model
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

sortMenuView : AppRoutes -> Session -> AppModel -> Html Msg
sortMenuView route session model =
    div [ class "filter-menu center" ]
        [ userMenuView route model
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

tagsFilterView : Session -> AppModel -> Html Msg
tagsFilterView session model =
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
      ) session.user.tags

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


userMenuView : AppRoutes -> AppModel -> Html Msg
userMenuView route model =
    ul [ class "group-btn" ]
        [ li [ class <| getActiveClass (route == UsersRoute "all") ]
            [ a [ class "button", href "http://localhost:3000/#/users/" ]
                [ text "Around me" ]
            ]
        , li [ class <| getActiveClass (route == UsersRoute "visitors") ]
            [ a [ class "button", href "http://localhost:3000/#/users/visitors" ]
                [ text "Visitors "
                , notif model.notifVisit
                ]
            ]
        , li [ class <| getActiveClass (route == UsersRoute "likers") ]
            [ a [ class "button", href "http://localhost:3000/#/users/likers" ]
                [ text "Likers "
                , notif model.notifLike
                ]
            ]
        , li []
            [ button [ class "btn-no-style", onClick ToggleAdvanceFilters ] [ text "..." ]
            ]
        ]


viewUsers : Session -> AppModel -> Html Msg
viewUsers session model =
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
                    List.sortBy (\u -> getAffinityScore session.user u) listF

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
                    li [] [ cardUserView u session model ]
                )
            <|
                listOrdered
        ]


cardUserView : User -> Session -> AppModel -> Html Msg
cardUserView user session model =
    Html.Keyed.node (String.filter Char.isLower user.username)
        []
        [ ( "div"
          , div [ class "user-box" ]
                [ userImageView user session model
                , userInfosView user model
                , a [ href <| "http://localhost:3000/#/user/" ++ user.username, class "user-link" ] []
                ]
          )
        ]


userInfosView : User -> AppModel -> Html Msg
userInfosView user model =
    div [ class "user-infos" ]
        [ userNameView user
        , userDistanceView user
        ]


userImageView : User -> Session -> AppModel -> Html Msg
userImageView user session model =
    let
        imgSrc =
            case List.head user.photos of
                Just src ->
                    src

                _ ->
                    "http://profile.actionsprout.com/default.jpeg"
    in

            div [ style [ ( "background", "url(" ++ imgSrc ++ ") center center no-repeat" ) ], class "img-box" ]
                [ div [ class "user-menu" ]
                    [ userLikeButtonView session user ]
                ]
