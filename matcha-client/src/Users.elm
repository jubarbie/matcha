module Users exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import List
import UserModel exposing (..)


view : Model -> Html Msg
view model =
    div [] [ viewUsers model.users model ]

viewUsers : List User -> Model -> Html Msg
viewUsers users model =
    div []
        [ ul [ class "users-list" ] <| List.map (\u ->
            li [] [ viewUser u model ]
            ) users
        ]

viewUser : User -> Model -> Html Msg
viewUser user model =
  let
    imgSrc = case List.head user.photos of
      Just src -> src
      _ -> "http://profile.actionsprout.com/default.jpeg"
  in
    div [ class "user-box" ]
        [ h3 [] [ text user.username ]
        , div [ style [("background", "url(" ++ imgSrc ++ ") center center no-repeat")], class "img-box" ][]
        , div [] [ text <| genderToString user.gender ]
        , div [] [ a [href <| "http://localhost:3000/#/user/" ++ user.username][ text "See profile" ] ]
        ]
