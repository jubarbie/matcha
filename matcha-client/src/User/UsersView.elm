module User.UsersView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Models exposing (..)
import Msgs exposing (..)
import List
import User.UserModel exposing (..)
import Utils exposing (..)
import User.UserView exposing (..)
import User.UserHelper exposing (..)


view : Model -> List (Html Msg)
view model =
    [ div [ ]
        [ sortMenuView model
        , viewUsers model.users model
        ]
    ]

sortMenuView : Model -> Html Msg
sortMenuView model =
  div [ class "filter-menu center" ]
      [ ul [ class "group-btn" ]
            [ li [ ][ button [ class "button", onClick <| ChangeSort S_Age ]
                    [ text "Age"]
                    ]
            , li [ ][ button [ class "button", onClick <| ChangeSort S_Dist ]
                    [ text "Distance"]
                    ]
            , li [ ][ button [ class "button", onClick <| ChangeSort S_LastOn ]
                    [ text "LastOn"]
                    ]
            ]
      , userMenuView model
      ]

userMenuView : Model -> Html Msg
userMenuView model =
      ul [ class "group-btn" ]
        [ li [ ][ a [ class "button", href "http://localhost:3000/#/users/" ]
                [ text "Around me"]
                ]
        , li [ ][ a [ class "button", href "http://localhost:3000/#/users/visitors" ]
                [ text "Visitors "
                , notif model.notifVisit ]
                ]
        , li [ ][ a [ class "button", href "http://localhost:3000/#/users/likers" ]
                [ text "Likers "
                , notif model.notifLike ]
                ]
        ]


viewUsers : List User -> Model -> Html Msg
viewUsers users model =
  let
    list = case model.userSort of
      S_Dist -> List.sortWith distanceCmp users
      S_Age -> List.sortBy .date_of_birth users
      S_LastOn -> List.sortBy .lastOn users
  in
    div []
        [ ul [ class <| "users-list" ] <|
          List.map (\u ->
              li [] [ cardUserView u model ]
              ) <| list
        ]

cardUserView : User -> Model -> Html Msg
cardUserView user model =
  div [ class "user-box" ]
        [ userImageView user model
        , userInfosView user model
        , a [ href <| "http://localhost:3000/#/user/" ++ user.username, class "user-link" ][ ]
        ]

userInfosView : User -> Model -> Html Msg
userInfosView user model =
  div [ class "user-infos" ]
      [ userNameView user
      , userDistanceView user
      ]

userImageView : User -> Model -> Html Msg
userImageView user model =
  let
    imgSrc = case List.head user.photos of
      Just src -> src
      _ -> "http://profile.actionsprout.com/default.jpeg"
  in
    case model.session of
      Just s ->
        div [ style [("background", "url(" ++ imgSrc ++ ") center center no-repeat")], class "img-box" ]
            [ div [ class "user-menu"]
                  [ userLikeButtonView s user ]
            ]
      _ -> div [][]
