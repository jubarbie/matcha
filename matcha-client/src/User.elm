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

view : Model -> Html Msg
view model =
    case (model.current_user, model.session) of
        (Just u, Just s)-> viewUser u s
        _ -> div [][ text <| "user not found" ]

viewUser : User -> Session -> Html Msg
viewUser user session =
  let
    talkTxt =
      if user.has_talk then
        "Open talk"
      else
        "New talk"
    likeBtn =
      if ( (user.match == None || user.match == From) && List.length session.user.photos > 0) then
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
  in
    div []
        [ button [ onClick <| GoBack 1 ][ text "Back" ]
        , h3 [] [ text user.username ]
        , likeBtn
        , if user.match == Match then
            a [ href <| "http://localhost:3000/#/chat/" ++ user.username ] [ text talkTxt ]
          else
            div [][ text "You haven't matched (yet) with this profile, you can't open a talk" ]
        , div [] [ text <| genderToString user.gender ]
        , div [] [ text <| "Last time seen: " ++ (formatDate last_connection) ]
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
