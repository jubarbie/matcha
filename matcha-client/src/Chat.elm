module Chat exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Date

import Models exposing (..)
import Msgs exposing (..)
import DateUtils exposing (..)
import Json.Decode

view : Model -> Html Msg
view model =
  case (model.route, model.current_talk) of
      (ChatRoute a, Just t) ->
        let
          messages = List.sortBy (\m -> m.date) t.messages
        in
          div [class "content"]
            [ button [ onClick <| GoBack 1 ][ text "Back" ]
            , h1 [] [text <| "Chat with " ++ a ]
            , div [ class "message-list" ] (List.map (messageView a) messages)
            , Html.form [ class "message-form" ]
              [ div [ class "message-input" ]
                [ input [ type_ "text", onInput UpdateNewMessage, value t.new_message ] []
                , button
                [ class "send-btn"
                , type_ "submit"
                , onWithOptions
                    "click"
                    { preventDefault = True
                    , stopPropagation = False
                    }
                    (Json.Decode.succeed SendNewMessage)
                ] [ text "Send" ] ]
              ]
            ]

      _ -> div [] [ text "No chat" ]

allChatsView : Model -> Html Msg
allChatsView model =
  case model.session of
        Just s ->
          if List.length s.user.talks > 0 then
            div [class "content"] <|
                List.map (\t -> div [] [ a [ href <| "/#/chat/" ++ t] [ text t ] ] ) s.user.talks
          else
            div [class "content"] [ text "You haven't talk to anyone yet" ]
        _ ->
          div [class "content"] [ text "No session..." ]


messageView : String -> Message -> Html Msg
messageView to msg =
  let
    date =
      case String.toFloat msg.date of
        Ok d -> Date.fromTime d
        _ -> Date.fromTime 0
    pos =
      if (to == msg.user) then
        "them"
      else
        "me"
  in
    div [ class <| "message message-" ++ pos]
      [ div [ class "message-infos" ]
        [ text <| formatDate date ++ " - "
        , text msg.user
        ]
      , div [ class "message-bubble" ] [  text msg.message ]
      ]
