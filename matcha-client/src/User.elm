module User exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import FormUtils exposing (..)
import UserModel exposing (..)


view : Model -> Html Msg
view model =
    case model.current_user of
        Just u -> viewUser u
        _ -> div [][ text <| "user not found" ]

viewUser : CurrentUser -> Html Msg
viewUser user =
  let
    talkTxt =
      if user.has_talk then
        "Open talk"
      else
        "New talk"
    likeBtn =
      if ( user.match == None || user.match == From ) then
        button [ onClick <| ToggleLike user.username ] [ text "Like" ]
      else
        div []
          [ text <|
              case user.match of
                Match -> "Matched"
                To -> "Liked"
                _ -> ""
          ]
  in
    div []
        [ button [ onClick <| GoBack 1 ][ text "Back" ]
        , h3 [] [ text user.username ]
        , likeBtn
        , a [ href <| "http://localhost:3000/#/chat/" ++ user.username ] [ text talkTxt ]
        , div [] [ text <| genderToString user.gender ]
        , div [] [ text user.bio ]
        ]
