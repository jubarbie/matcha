module Chat exposing (..)

import Html exposing (..)

import Models exposing (..)
import Msgs exposing (..)


view : Model -> Html Msg
view model =
    div []
        [text "chat"]

allChatsView : Model -> Html Msg
allChatsView model =
  let
    talks =
      case model.session of
        Just s -> s.user.talks
        _ -> []
  in
    div [] <| 
        List.map text talks
