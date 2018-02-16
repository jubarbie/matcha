module User.UsersView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import List
import User.UserModel exposing (..)
import Utils exposing (..)
import User.UserView exposing (..)
import User.UserHelper exposing (..)


view : Model -> List (Html Msg)
view model =
    [ div [ class <| "content" ]
        [ userMenuView model
        , viewUsers model.users model
        ]
    ]

userMenuView : Model -> Html Msg
userMenuView model =
  div [ class "filter-menu center" ]
      [ ul [ class "group-btn" ]
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
      ]

viewUsers : List User -> Model -> Html Msg
viewUsers users model =
    div []
        [ ul [ class <| "users-list" ] <|
          List.map (\u ->
              li [] [ cardUserView u model ]
              ) <| List.sortWith distanceCmp users
        ]

cardUserView : User -> Model -> Html Msg
cardUserView user model =
    div [ class "user-box" ]
        [ userImageView user model
        , div [ class "user-infos" ]
          [ h3 [] [ text user.username ]
          , div [class "u-pull-right"] [ genderToIcon user.gender ]
          , icon "fas fa-location-arrow"
          , text <| case user.distance of
                Just d ->
                    case d < 1 of
                      True -> (++) (toString <| round (d * 1000 )) " m away"
                      _ -> (++) (toString <| round d) " km away"
                _ -> ""
          ]
        , a [ href <| "http://localhost:3000/#/user/" ++ user.username, class "user-link" ][ ]
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
