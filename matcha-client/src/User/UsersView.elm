module User.UsersView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import List
import User.UserModel exposing (..)
import Utils exposing (..)
import User.UserView exposing (..)


view : Model -> List (Html Msg)
view model =
    [ div [ class <| "content" ]
        [ userMenuView model
        , viewUsers model.users model
        ]
    ]

userMenuView : Model -> Html Msg
userMenuView model =
  div [ class "center" ]
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

distanceCmp a b =
    case (a.distance, b.distance) of
      (Just d1, Just d2) -> compare d1 d2
      (Just d1, _ ) -> LT
      _ -> EQ

cardUserView : User -> Model -> Html Msg
cardUserView user model =
  let
    imgSrc = case List.head user.photos of
      Just src -> src
      _ -> "http://profile.actionsprout.com/default.jpeg"
  in
    div [ class "user-box" ]
        [ h3 [] [ text user.username ]
        , div [ style [("background", "url(" ++ imgSrc ++ ") center center no-repeat")], class "img-box" ][]
        , div []
          [ div [class "u-pull-right"] [ genderToIcon user.gender ]
          , text <| case user.distance of
                Just d ->
                    case d < 1 of
                      True -> (++) (toString <| round (d * 1000 )) " m away"
                      _ -> (++) (toString <| round d) " km away"
                _ -> ""
          ]
        , a [ href <| "http://localhost:3000/#/user/" ++ user.username, class "user-link" ][ ]
        ]
