module User.UserView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Models exposing (..)
import Msgs exposing (..)
import FormUtils exposing (..)
import User.UserModel exposing (..)
import User.UserHelper exposing (..)
import Utils exposing (..)
import Date


view : String -> Model -> List (Html Msg)
view username model =
  case (findUserByName username model.users, model.session) of
      (Just user, Just s) ->
        [ div [ id "single-user", onClick <| GoBack 1 ]
          [
            div [ class "container" ]
                [ div [ class "user-box appear" ]
                      [ userImagesView user model
                      , div [ class "user-infos" ]
                            [ userNameView user
                            , userLikeButtonView s user
                            , userMatchStatusView user
                            , userTagsView user
                            , userBioView user
                            , userDistanceView user
                            , userOnlineStatusView model user
                            ]
                      ]
                ]
            ]
        ]
      _ ->
        [ div [] [ text <| "No user with name " ++ username ] ]


userLikeButtonView : Session -> User -> Html Msg
userLikeButtonView session user =
  let
    match = getMatchStatus user
    likeClass =
      if (match == To || match == Match) then
        " liked"
      else
        ""
    options =
        { stopPropagation = True
        , preventDefault = False
        }
  in
    if (List.length session.user.photos <= 0) then
      div [] []
    else
      button
        [ onWithOptions "click" options ( Decode.succeed <| ToggleLike user.username )
        , class <| "like-btn" ++ likeClass ] [ icon "fas fa-heart"
        ]

userMatchStatusView : User -> Html Msg
userMatchStatusView user =
  let
    talkTxt =
      if user.has_talk then
        "fas fa-comments"
      else
        "far fa-comments"
    options =
      { stopPropagation = True
      , preventDefault = False
      }
  in
   if getMatchStatus user == Match then
      button
        [ onWithOptions "click" options ( Decode.succeed <| GoTo <| "http://localhost:3000/#/chat/" ++ user.username ), class "talk-btn" ]
        [ i [ class talkTxt ] [] ]
    else
      div [][]

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
          div [ class "online-status on" ] [ text "Online ", icon "fas fa-circle" ]
        else
          div [ class "online-status off" ] [ text <| "Last time seen: " ++ (formatDate last_connection) ++ " ", icon "fas fa-circle" ]

userNameView : User -> Html Msg
userNameView user =
  h3 [] [ text user.username, div [ class "u-pull-right" ] [ genderToIcon user.gender ] ]


userDistanceView : User -> Html Msg
userDistanceView user =
  div [ class "info-dist" ]
      [ icon "fas fa-location-arrow"
      , text <| if user.distance < 1 then
                  " " ++ (toString <| round (user.distance * 1000 )) ++ " m away"
                else
                  " " ++ (toString <| round user.distance) ++ " km away"
      ]

userBioView : User -> Html Msg
userBioView user =
  div [ class "user-bio" ] [ text user.bio ]

userTagsView : User -> Html Msg
userTagsView user =
  div [] <| List.map (\t ->
      div [ class "tag" ]
          [ text t ]) (List.sort user.tags)

userImagesView : User -> Model -> Html Msg
userImagesView user model =
  let
    imgSrc = case List.head user.photos of
      Just src -> src
      _ -> "http://profile.actionsprout.com/default.jpeg"
  in
    case model.session of
      Just s ->
        div [ style [("background", "url(" ++ imgSrc ++ ") center center no-repeat")], class "img-box" ]
            <| (galleryButtonView user.photos user)
      _ -> div [][]

galleryButtonView : List String -> User -> List (Html Msg)
galleryButtonView gal user =
  let
    options =
      { stopPropagation = True
      , preventDefault = False
      }
  in
    if List.length gal > 1 then
      [ div [ class "gal-btn " ]
            [ button [ onWithOptions "click" options ( Decode.succeed <| ChangeImage user -1 ) ] [ icon "fas fa-chevron-left" ]
            , button [ onWithOptions "click" options ( Decode.succeed <| ChangeImage user 1 ) ] [ icon "fas fa-chevron-right" ]
            ]
      ]
    else
      []
