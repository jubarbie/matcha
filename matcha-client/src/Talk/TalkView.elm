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


view : Maybe Talk -> List (Html Msg)
view talk =
  case talk of
    Just t ->
      let
          messages =
              List.sortBy (\m -> m.date) t.messages
      in
        [ div [ class "layout" ]
            [ button [ onClick <| GoBack 1 ] [ i [ class "fas fa-caret-left" ] [], text " Back" ]
            , h1 [ class "flex" ] [ text <| "Chat with " ++ t.username_with ]
            ]
        ]
            ++ [ div [ id "talk-list", class "message-list content" ] (List.map (messageView t.username_with) messages) ]
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


allChatsView : Model -> Html Msg
allChatsView model =
    if List.length model.talks > 0 then
        div [ class "content" ] <|
            List.map (\t -> div [] [ a [ href <| "/#/chat/" ++ t.username_with ] [ text <| t.username_with, notif t.unreadMsgs ] ]) model.talks
    else
        div [ class "content" ] [ text "You haven't talk to anyone yet" ]



notif : Int -> Html Msg
notif notif =
    if notif > 0 then
        span [ class "notif" ] [ text <| toString notif ]
    else
        span [] []


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
