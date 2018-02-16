module User.UserView exposing (..)

import Html exposing (..)
import Html.Keyed exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import FormUtils exposing (..)
import User.UserModel exposing (..)
import User.UserHelper exposing (..)
import Utils exposing (..)
import Date


view : String -> Model -> Html Msg
view username model =
  case (findUserByName username model.users, model.session) of
    (Just user, Just s) ->
      Html.Keyed.node username [ ]
        [ ( "div",
          div []
          [ h3 [] [ text user.username ]
          , button [onClick <| GoBack 1][text "back"]
          , userLikeButtonView s user
          , userMatchStatusView user
          , genderToIcon user.gender
          , userDistanceView user
          , userOnlineStatusView model user
          , userTagsView user
          , userBioView user
          , userImagesView user
          ]
          )]
    _ ->
      div [] [ text <| "No user with name " ++ username ]


userLikeButtonView : Session -> User -> Html Msg
userLikeButtonView session user =
  let
    match = getMatchStatus user
    likeClass =
      if (match == To || match == Match) then
        " liked"
      else
        ""
  in
    if (List.length session.user.photos <= 0) then
      div [] [ text "You have to upload at least one image to be able to like this person" ]
    else
      button [ onClick <| ToggleLike user.username, class <| "like-btn" ++ likeClass ] [ icon "fas fa-heart" ]

userMatchStatusView : User -> Html Msg
userMatchStatusView user =
  let
    talkTxt =
      if user.has_talk then
        "fas fa-comments"
      else
        "far fa-comments"
  in
   if getMatchStatus user == Match then
      a [ href <| "http://localhost:3000/#/chat/" ++ user.username ] [ i [ class talkTxt ] [] ]
    else
      div [][ text "You haven't matched (yet) with this profile, you can't open a talk" ]

userDistanceView : User -> Html Msg
userDistanceView user =
  div []
    [ text <| case user.distance of
        Just d -> (++) (toString <| round (d * 1000 )) " meters away"
        _ -> ""
    ]

userOnlineStatusView : Model -> User -> Html Msg
userOnlineStatusView model user =
  let
      last_connection =
        case String.toFloat user.lastOn of
          Ok d -> Date.fromTime d
          _ -> Date.fromTime 0
      online =
        case (String.toFloat user.lastOn, model.currentTime) of
          (Ok l, Just ct) ->
            if (l > ct - 900000) then
              True
            else False
          _ -> False
  in
      if online then
          div [][ text "Online"]
        else
          div [] [ text <| "Last time seen: " ++ (formatDate last_connection) ]

userBioView : User -> Html Msg
userBioView user =
  div [] [ text user.bio ]

userTagsView : User -> Html Msg
userTagsView user =
  div [] <| List.map (\t ->
      div [ class "tag" ]
          [ text t ]) (List.sort user.tags)

userImagesView : User -> Html Msg
userImagesView user =
  div [] <|
    List.map (\s ->
       div [ style [("background", "url(" ++ s ++ ") center center no-repeat")], class "img-box" ]
            []
      ) user.photos
