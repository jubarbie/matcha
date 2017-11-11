module Users exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import List
import UserModel exposing (..)


view : Model -> Html Msg
view model =
    div [] [ viewUsers model.users ]

viewUsers : List User -> Html Msg
viewUsers users =
    div []
        [ ul [ class "users-list" ] <| List.map (\u ->
            li [] [ viewUser u ]
            ) users
        ]

viewUser : User -> Html Msg
viewUser user =
  let
    imgSrc = case List.head user.photos of
      Just src -> src
      _ -> "http://profile.actionsprout.com/default.jpeg"
  in
    div [ class "user-box" ]
        [ h3 [] [ text <| Debug.log "username" user.username ]
        , div [ id "profile-img" ] [ img [ src imgSrc ] [] ]
        , div [] [ text <| genderToString user.gender ]
        , div [] [ a [href <| "http://localhost:3000/#/user/" ++ user.username][ text "See profile" ] ]
        ]
