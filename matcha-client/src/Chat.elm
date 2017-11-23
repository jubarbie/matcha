module Chat exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Date

import Models exposing (..)
import Msgs exposing (..)
import DateUtils exposing (..)

view : Model -> Html Msg
view model =
  case (model.route, model.current_talk) of
      (ChatRoute a, Just t) ->
        let
          messages = List.sortBy (\m -> m.date) t.messages
        in
          div []
            [ button [ onClick <| GoBack 1 ][ text "Back" ]
            , h1 [] [text <| "Chat with " ++ a ]
            , div [] (List.map (messageView a) messages)
            , div [] [ textarea [ onInput UpdateNewMessage, value t.new_message ] [] ]
            , div [] [ button [ onClick SendNewMessage ] [ text "Send" ] ]
            ]

      _ -> div [] [ text "No chat" ]

allChatsView : Model -> Html Msg
allChatsView model =
  case model.session of
        Just s ->
          if List.length s.user.talks > 0 then
            div [] <|
                List.map (\t -> div [] [ a [ href <| "/#/chat/" ++ t] [ text t ] ] ) s.user.talks
          else
            div [] [ text "You haven't talk to anyone yet" ]
        _ ->
          div [] [ text "No session..." ]


messageView : String -> Message -> Html Msg
messageView to msg =
  let
    date =
      case String.toFloat msg.date of
        Ok d -> Date.fromTime d
        _ -> Date.fromTime 0
    pos =
      if (to == msg.user) then
        "left"
      else
        "right"
  in
    div [ style [("text-align", pos)]]
      [ div []
        [ text <| formatDate date
        , text msg.user
        ]
      , div [] [  text msg.message ]
      ]
