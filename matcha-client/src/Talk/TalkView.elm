module Talk.TalkView exposing (..)

import Date
import Utils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Models exposing (..)
import Msgs exposing (..)
import String
import Talk.TalkModel exposing (..)
import Talk.TalkUtils exposing (..)


view : String -> Model -> List (Html Msg)
view talk model =
  case getTalkWith talk model.talks of
    Just t ->
      let
          messages =
              List.sortBy (\m -> m.date) t.messages
      in
        [ div [ class "chat-title" ]
              [ div [ class "container" ]
                    [ button [ onClick <| GoBack 1, class "pull-left" ] [ i [ class "fas fa-caret-left" ] [], text " Back" ]
                    , h1 [] [ text <| "Chat with " ++ t.username_with ]
                    ]
              ]
        ]
            ++ [ div [ id "talk-list", class "message-list" ] (List.map (messageView t.username_with) messages) ]
            ++ viewMessageForm t
    _ -> [ text "No talk" ]



viewMessageForm : Talk -> List (Html Msg)
viewMessageForm t =
    [ Html.form [ class "footer message-form" ]
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
                ]
                [ i [ class "fas fa-share" ] [] ]
            ]
        ]
    ]


talksListView : Model -> Html Msg
talksListView model =
    if List.length model.talks > 0 then
        ul [ class "content talk-list" ] <|
            List.map (\t -> li [] [ a [ href <| "/#/chat/" ++ t.username_with ] [ text <| t.username_with, notif t.unreadMsgs ] ]) model.talks
    else
        div [ class "content" ] [ text "You haven't talk to anyone yet" ]


messageView : String -> Message -> Html Msg
messageView to msg =
    let
        date =
            case String.toFloat msg.date of
                Ok d ->
                    Date.fromTime d

                _ ->
                    Date.fromTime 0

        pos =
            if to == msg.user then
                "them"
            else
                "me"
    in
    div [ class <| "message message-" ++ pos ]
        [ div [ class "message-infos" ]
            [ text <| formatDate date ++ " - "
            , text msg.user
            ]
        , div [ class "message-bubble" ] [ text msg.message ]
        ]
