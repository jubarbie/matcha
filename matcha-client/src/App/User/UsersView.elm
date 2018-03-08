module App.User.UsersView exposing (view, searchView)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import List
import Models exposing (..)
import Msgs exposing (..)
import App.User.UserHelper exposing (..)
import App.User.UserModel exposing (..)
import App.User.UserView exposing (..)
import Utils exposing (..)
import Json.Decode as Decode
import App.AppModels exposing (..)


view : AppRoutes -> Session -> AppModel -> UsersModel -> List (Html Msg)
view route session appModel model =
    [ div []
          [ usersMenuView route session appModel model
          , viewUsers session appModel model
          ]
    ]

searchView : AppRoutes -> Session -> AppModel -> UsersModel -> List (Html Msg)
searchView route session appModel model =
  if List.length model.users == 0 then
    [ div [ id "advance-search", class "center" ]
          [ div [  class <| "center" ++ if appModel.showAdvanceFilters then " active" else "" ]
              [ div [ class "layout-row xs-no-flex" ]
                    [ ageSearchView appModel.search
                    , locSearchView appModel.search
                    ]
              , tagsSearchView session appModel
              , button [ onClick ResetSearch, class "btn-no-style" ] [ text "Reset" ]
              ]
          , button [ onClick AdvanceSearch ] [ text "Search" ]
          ]
    ]
  else
    [ div []
          [ div [ class "filter-menu center" ]
                [ div [ class "layout xs-no-flex" ] [ sortMenuView model ] ]
          , viewUsers session appModel model
          ]
    ]

tagsSearchView : Session -> AppModel -> Html Msg
tagsSearchView session model =
  div [ class "center"]
    <|  List.map (\t ->
        let
            me =
                if List.member t model.search.tags then
                    " metoo"
                else
                    ""
        in
      button [ class <| "tag" ++ me, onClick <| UpdateSearchTags t ]
        [ text <| "#" ++ t ]
      ) session.user.tags

ageSearchView : SearchModel -> Html Msg
ageSearchView model =
  div [ class "layout-column flex align-center" ]
      [ div [ class "layout" ]
            [ div [] [ text "From "]
            , div []
                  [ select [ onInput UpdateMinYearSearch ]
                    <| option ([ value "No" ] ++ (if model.yearMin == Nothing then [ Html.Attributes.attribute "selected" "selected" ] else [])) [ text "No" ] :: List.map (\a ->
                      option
                        ([ value <| toString a ] ++ (if model.yearMin == Just a then [ Html.Attributes.attribute "selected" "selected" ] else [])) [ text <| toString a ]
                      ) (List.range 18 98)
                  ]
            , div [] [ text " to " ]
            , div []
                  [ select [ onInput UpdateMaxYearSearch ]
                    <| option ([ value "No" ] ++ (if model.yearMax == Nothing then [ Html.Attributes.attribute "selected" "selected" ] else [])) [ text "No" ] :: List.map (\a ->
                      option ([ value <| toString a ] ++ (if model.yearMax == Just a then [ Html.Attributes.attribute "selected" "selected" ] else [])) [ text <| toString a ]
                    ) (List.range 18 98)
                  ]
            , div [][text " years old"]
            ]
      ]

locSearchView : SearchModel -> Html Msg
locSearchView model =
  div [ class "layout-column flex align-center" ]
      [ div [ class "layout" ]
            [ div [][ text "Less than"]
            , select [ onInput UpdateLocSearch ]
              <| option ([ value "No" ] ++ (if model.loc == Nothing then [ Html.Attributes.attribute "selected" "selected" ] else [])) [ text "No" ] :: List.map (\v ->
                option ([ value <| toString v ] ++ (if model.loc == Just v then [ Html.Attributes.attribute "selected" "selected" ] else [])) [ text <| toString v ]
              ) [ 1, 5, 10, 20, 50, 100, 200, 500 ]
            , div [][text " km away"]
            ]
      ]

advanceFilterView : Session -> AppModel -> UsersModel -> Html Msg
advanceFilterView session appModel model =
  div [ id "advance-filters", class <| "center" ++ if appModel.showAdvanceFilters then " active" else "" ]
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
            [ div [][ text "Less than"]
            , select [ onInput UpdateLocFilter ] <| List.map (\v -> option [ value <| toString v ] [ text <| toString v ] ) [ 1, 5, 10, 20, 50, 100, 200, 500 ]
            , div [][text " km away"]
            ]
      ]

sortMenuView : UsersModel -> Html Msg
sortMenuView model =
  ul [ class "group-btn" ]
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
  div [ class "center"]
    <|  List.map (\t ->
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
  div [ class "layout-column flex align-center" ]
      [ div [ class "layout" ]
            [ div [] [ text "From "]
            , div []
                  [ select [ onInput UpdateMinAgeFilter ]
                    <| option [ value "No"] [ text "No" ] :: List.map (\a -> option [ value <| toString a ] [ text <| toString a ] ) (List.range 18 98)
                  ]
            , div [] [ text " to " ]
            , div []
                  [ select [ onInput UpdateMaxAgeFilter ]
                    <| option [ value "No"] [ text "No" ] :: List.map (\a -> option [ value <| toString a ] [ text <| toString a ] ) (List.range 18 98)
                  ]
            , div [][text " years old"]
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
        , li [ class <| getActiveClass (route == UsersRoute "matchers") ]
            [ a [ class "button", href "http://localhost:3000/#/users/matchers" ]
                [ text "Matchers "
                , notif model.notifLike
                ]
            ]
        , li [ class <| getActiveClass model.showAdvanceFilters ]
            [ button [ class "btn-no-style", onClick ToggleAdvanceFilters ] [ icon "fas fa-filter" ]
            ]
        ]


viewUsers : Session -> AppModel -> UsersModel -> Html Msg
viewUsers session appModel model =
  let
    view =
      if List.length model.users == 0 then
        emptyUsersView
      else
        viewUsersList session appModel model
  in
      div [ id "users-list", class "layout-column" ]
          [ view
          ]

emptyUsersView : Html Msg
emptyUsersView =
  div [ class "layout-column flex center" ] [ text "No users" ]

viewUsersList : Session -> AppModel -> UsersModel -> Html Msg
viewUsersList session appModel model =
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
              List.reverse list |> List.indexedMap (,)
          else
              list |> List.indexedMap (,)
  in
    ul [ class <| "users-list" ] <|
        List.map
            (\(i, u) ->
                li [] [ cardUserView u i session model ]
            )
        <|
            listOrdered

cardUserView : User -> Int -> Session -> UsersModel -> Html Msg
cardUserView user i session model =
    Html.Keyed.node (String.filter Char.isLower user.username)
        []
        [ ( "div"
          , div [ class <| "user-box animated fadeInUp", style [("animation-delay", toString (toFloat i/10) ++ "s"), ("animation-duration", ".3s")] ]
                [ userImageView user session model
                , userInfosView user model
                , a [ href <| "http://localhost:3000/#/user/" ++ user.username, class "user-link" ] []
                ]
          )
        ]


userInfosView : User -> UsersModel -> Html Msg
userInfosView user model =
    div [ class "user-infos" ]
        [ userNameView user
        , userDistanceView user
        ]


userImageView : User -> Session -> UsersModel -> Html Msg
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
