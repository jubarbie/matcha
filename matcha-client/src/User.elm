module User exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import FormUtils exposing (..)
import UserModel exposing (..)
import DateUtils exposing (..)
import Date
import Helper exposing (..)

view : Model -> Html Msg
view model =
    case (model.current_user, model.session) of
        (Just u, Just s)-> viewUser u s model
        _ -> div [][ text <| "user not found" ]

viewUser : User -> Session -> Model -> Html Msg
viewUser user session model =
  let
    talkTxt =
      if user.has_talk then
        "fas fa-comments"
      else
        "far fa-comments"
    likeBtn =
      if (List.length session.user.photos <= 0) then
        div [] [ text "You have to upload at least one image to be able to like this person" ]
      else if (user.match == None || user.match == From) then
        button [ onClick <| ToggleLike user.username ] [ text "Like" ]
      else
        div []
          [ text <|
              case user.match of
                Match -> "Matched"
                To -> "Liked"
                _ -> ""
          ]

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
    div [class "content"]
        [ button [ onClick <| GoBack 1 ][ text "Back" ]
        , h3 [] [ text user.username ]
        , likeBtn
        , if user.match == Match then
            a [ href <| "http://localhost:3000/#/chat/" ++ user.username ] [ i [ class talkTxt ] [] ]
          else
            div [][ text "You haven't matched (yet) with this profile, you can't open a talk" ]
        , genderToIcon user.gender
        , div []
          [ text <| case user.distance of
              Just d -> (++) (toString <| round (d * 1000 )) " meters away"
              _ -> ""
          ]
        , if online then
            div [][ text "Online"]
          else
            div [] [ text <| "Last time seen: " ++ (formatDate last_connection) ]
        , div [] <| List.map (\t ->
            div [ class "tag" ]
                [ text t ]) (List.sort user.tags)
        , div [] [ text user.bio ]
        , (if List.length user.photos > 0 then
           div [] <| List.map (\s ->
             div [ style [("background", "url(" ++ s ++ ") center center no-repeat")], class "img-box" ]
                  []
            ) user.photos
           else div [] [] )
        ]
