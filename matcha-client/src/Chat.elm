module Chat exposing (..)

import Date
import DateUtils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Models exposing (..)
import Msgs exposing (..)
import String
import UserModel exposing (..)


view : Model -> List (Html Msg)
view model =
    case ( model.route, model.session ) of
        ( ChatRoute a, Just s ) ->
            case getTalkWith a s.user.talks of
                Just t ->
                    let
                        messages =
                            List.sortBy (\m -> m.date) t.messages
                    in
                    [ div [ class "layout" ]
                        [ button [ onClick <| GoBack 1 ] [ i [ class "fas fa-caret-left" ] [], text " Back" ]
                        , h1 [ class "flex" ] [ text <| "Chat with " ++ a ]
                        ]
                    ]
                        ++ [ div [ id "talk-list", class "message-list content" ] (List.map (messageView a) messages) ]
                        ++ viewMessageForm t

                _ ->
                    [ div [] [ text "No chat" ] ]

        _ ->
            [ div [] [ text "No chat" ] ]


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
    case model.session of
        Just s ->
            if List.length s.user.talks > 0 then
                div [ class "content" ] <|
                    List.map (\t -> div [] [ a [ href <| "/#/chat/" ++ t.username_with ] [ text <| t.username_with, notif t.unreadMsgs ] ]) s.user.talks
            else
                div [ class "content" ] [ text "You haven't talk to anyone yet" ]

        _ ->
            div [ class "content" ] [ text "No session..." ]


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


getTalkWith : String -> List Talk -> Maybe Talk
getTalkWith username talks =
    List.head <| List.filter (\t -> t.username_with == username) talks


updateTalks : Maybe Talk -> List Talk -> List Talk
updateTalks newTalk talks =
    case newTalk of
        Just nt ->
            List.map
                (\t ->
                    if nt.username_with == t.username_with then
                        nt
                    else
                        t
                )
                talks

        _ ->
            talks
