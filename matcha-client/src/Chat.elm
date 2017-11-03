module Chat exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Date

import Models exposing (..)
import Msgs exposing (..)


view : Model -> Html Msg
view model =
  case (model.route, Debug.log "current_talk" model.current_talk) of
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
  let
    talks =
      case model.session of
        Just s -> s.user.talks
        _ -> []
  in
    div [] <|
        List.map (\t -> div [] [ a [ href <| "/#/chat/" ++ t] [ text t ] ] ) talks

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

formatDate : Date.Date -> String
formatDate date =
  let
    year = toString <| Date.year date
    month =
      case Date.month date of
        Date.Jan -> "jan"
        Date.Feb -> "feb"
        Date.Mar -> "mar"
        Date.Apr -> "apr"
        Date.May -> "may"
        Date.Jun -> "jun"
        Date.Jul -> "jul"
        Date.Aug -> "aug"
        Date.Sep -> "sep"
        Date.Oct -> "oct"
        Date.Nov -> "nov"
        Date.Dec -> "dec"
    day = toString <| Date.day date
    h = toString <| Date.hour date
    m = toString <| Date.minute date
    s = toString <| Date.second date
  in
    day ++ " " ++ month ++ " " ++ year ++ " " ++ h ++ ":" ++ m ++ ":" ++ s
