module Chat exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

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
            [ h1 [] [text <| "Chat with " ++ a ]
            , div [] (List.map messageView messages)
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

messageView : Message -> Html Msg
messageView msg =
  div []
    [ div []
      [ text msg.date
      , text msg.user
      ]
    , div [] [  text msg.message ]
    ]
