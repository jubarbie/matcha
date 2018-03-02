module App.Talk.TalkView exposing (..)

import Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Models exposing (..)
import Msgs exposing (..)
import Regex exposing (..)
import String
import App.AppModels exposing (..)
import App.Talk.TalkModel exposing (..)
import App.Talk.TalkUtils exposing (..)
import Utils exposing (..)


view : String -> AppRoutes -> AppModel -> List (Html Msg)
view talk route model =
    case getTalkWith talk model.talks of
        Just t ->
            let
                messages =
                    List.sortBy (\m -> m.date) t.messages
            in
            [ div [ class "layout-row flex" ]
                [ div
                    [ id "talk", class <| "layout-column" ++ getEmoListClass model.showEmoList ]
                    [ div [ id "talk-list", class "message-list content" ] (List.map (messageView t.username_with) messages)
                    , div [ id "talk-foot" ]
                        [ emoListView emoticonList talk
                        , viewMessageForm t
                        ]
                    ]
                , div [ id "talks-side" ] [ talksListView route model ]
                ]
            ]

        _ ->
            [ text "No talk" ]


getEmoListClass : Bool -> String
getEmoListClass sh =
    if sh then
        " show-emo"
    else
        ""


viewMessageForm : Talk -> Html Msg
viewMessageForm t =
    div [ id "new-mess" ]
        [ button [ onClick ToggleEmoList, class "emo-btn" ] [ icon "em em-grinning" ]
        , Html.form [ id "message-form" ]
            [ div [ class "message-input" ]
                [ input [ id "input-msg", type_ "text", onInput UpdateNewMessage, value t.new_message ] []
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


talksListView : AppRoutes -> AppModel -> Html Msg
talksListView route model =
    let
        current =
            case route of
                TalkRoute a ->
                    a

                _ ->
                    ""
    in
      if List.length model.talks > 0 then
          ul [ class "content talk-list" ] <|
              List.map
                  (\t ->
                      li
                          [ class <|
                              if current == t.username_with then
                                  "current"
                              else
                                  ""
                          ]
                          [ a [ href <| "/#/chat/" ++ t.username_with ] [ text <| t.username_with, notif t.unreadMsgs ] ]
                  )
                  model.talks
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
        , div [ class "message-bubble" ] (messageEmoticonView msg.message)
        ]


messageEmoticonView : String -> List (Html Msg)
messageEmoticonView msg =
    let
        reg =
            regex "::(__em-.*?__)::"

        listStr =
            split All reg msg
    in
    List.map
        (\s ->
            if contains (regex "__em-.*?__") s then
                emoticon (String.slice 2 -2 s)
            else
                text s
        )
        listStr


emoListView : List String -> String -> Html Msg
emoListView emo talk =
    div [ id "emo-list" ] <|
        List.map
            (\em ->
                i [ class <| "em " ++ em, onClick <| AddEmo talk em ] []
            )
            emo
