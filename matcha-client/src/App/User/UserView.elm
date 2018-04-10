module App.User.UserView exposing (..)

import App.AppModels exposing (..)
import App.User.UserHelper exposing (..)
import App.User.UserModel exposing (..)
import Date
import FormUtils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Json.Decode as Decode
import Models exposing (..)
import Msgs exposing (..)
import Utils exposing (..)


view : String -> Session -> AppModel -> UsersModel -> Html Msg
view username session appModel model =
    let
        view =
            case findUserByName username model.users of
                Just user ->
                    [ userImagesView user session
                    , div [ class "user-infos" ]
                        [ userNameView user
                        , userTagsView user session
                        , userBioView user
                        , userReportView user.username
                        , userDistanceView user
                        , userOnlineStatusView appModel user
                        ]
                    ]

                _ ->
                    [ div [ class "user-infos" ] [ text <| "No user with name " ++ username ] ]
    in
    div [ class "user-box appear" ] view


userButtonsView : Session -> User -> Html Msg
userButtonsView s user =
    div [ class "user-btns layout-row space-between" ]
        [ div []
            [ userLikeButtonView s user
            , userMatchStatusView user
            ]
        , userPopuView user
        ]


userReportView : String -> Html Msg
userReportView username =
    div [ class "text-right" ]
        [ button [ class "btn-no-style", onClick <| ReportUser username ] [ text "block" ]
        , text " "
        , button [ class "btn-no-style", onClick <| BlockUser username ] [ text "report" ]
        ]


userPopuView : User -> Html Msg
userPopuView user =
    div [ class "pull-right" ] <|
        List.indexedMap (getStar user.likes) [ 5, 10, 50, 100, 250 ]


getStar : Int -> Int -> Int -> Html Msg
getStar likes index step =
    let
        att =
            if (index % 2) /= 0 then
                [ Html.Attributes.attribute "data-fa-transform" "flip-h" ]
            else
                []
    in
    if likes >= step then
        i ([ class "fas fa-star" ] ++ att) []
    else
        i ([ class "far fa-star" ] ++ att) []


userLikeButtonView : Session -> User -> Html Msg
userLikeButtonView session user =
    let
        match =
            getMatchStatus user

        likeClass =
            if match == To || match == Match then
                " liked"
            else
                ""

        ico =
            case match of
                To ->
                    Html.Keyed.node "to"
                        [ class "fas fa-arrow-up"
                        , Html.Attributes.attribute "data-fa-transform" "shrink-10 up-.5"
                        , Html.Attributes.attribute "data-fa-mask" "fas fa-heart"
                        ]
                        []

                From ->
                    Html.Keyed.node "from"
                        [ class "fas fa-arrow-down"
                        , Html.Attributes.attribute "data-fa-transform" "shrink-10 up-.5"
                        , Html.Attributes.attribute "data-fa-mask" "fas fa-heart"
                        ]
                        []

                Match ->
                    img [ src "http://localhost:3001/images/logo_only.svg", width 35, style [ ( "margin-top", "5px" ), ( "fill", "orange" ) ] ] []

                _ ->
                    Html.Keyed.node "nada" [ class "fas fa-heart" ] []

        options =
            { stopPropagation = True
            , preventDefault = False
            }
    in
    if List.length session.user.photos <= 0 then
        div [] []
    else
        button
            [ onWithOptions "click" options (Decode.succeed <| ToggleLike user.username)
            , class <| "like-btn" ++ likeClass
            ]
            [ ico
            ]


userMatchStatusView : User -> Html Msg
userMatchStatusView user =
    let
        talkTxt =
            if user.has_talk then
                "fas fa-comments"
            else
                "far fa-comments"

        options =
            { stopPropagation = False
            , preventDefault = False
            }
    in
    if getMatchStatus user == Match then
        button
            [ onWithOptions "click" options (Decode.succeed <| SetCurrentTalk user.username), class "talk-btn" ]
            [ i [ class talkTxt ] [] ]
    else
        div [] []


userOnlineStatusView : AppModel -> User -> Html Msg
userOnlineStatusView model user =
    let
        last_connection =
            case String.toFloat user.lastOn of
                Ok d ->
                    Date.fromTime d

                _ ->
                    Date.fromTime 0

        online =
            case ( String.toFloat user.lastOn, model.currentTime ) of
                ( Ok l, Just ct ) ->
                    if l > ct - 7200000 && user.online then
                        True
                    else
                        False

                _ ->
                    False
    in
    if online then
        div [ class "online-status on" ] [ text "Online ", icon "fas fa-circle" ]
    else
        div [ class "online-status off" ] [ text <| "Last time seen: " ++ formatDate last_connection ++ " ", icon "fas fa-circle" ]


userNameView : User -> Html Msg
userNameView user =
    h3 []
        [ text <| user.username
        , text ", "
        , text <| toString (2018 - user.date_of_birth)
        , div [ class "u-pull-right" ] [ genderToIcon user.gender ]
        ]


userDistanceView : User -> Html Msg
userDistanceView user =
    div [ class "info-dist" ]
        [ icon "fas fa-location-arrow"
        , text <|
            if user.distance < 1 then
                " " ++ (toString <| round (user.distance * 1000)) ++ " m away"
            else
                " " ++ (toString <| round user.distance) ++ " km away"
        ]


userBioView : User -> Html Msg
userBioView user =
      div [ class "user-bio" ] [ text user.bio ]


userTagsView : User -> Session -> Html Msg
userTagsView user s =
    div [ class "center" ] <|
        List.map
            (\t ->
                let
                    me =
                        if List.member t s.user.tags then
                            " metoo"
                        else
                            ""
                in
                div [ class <| "tag" ++ me ]
                    [ text <| "#" ++ t ]
            )
            (List.sort user.tags)


userImagesView : User -> Session -> Html Msg
userImagesView user session =
    let
        imgSrc =
            case List.head user.photos of
                Just src ->
                    src

                _ ->
                    "http://profile.actionsprout.com/default.jpeg"
    in
    div [ style [ ( "background", "url(" ++ imgSrc ++ ") center center no-repeat" ) ], class "img-box" ] <|
        galleryButtonView user.photos user
            ++ [ userButtonsView session user ]


galleryButtonView : List String -> User -> List (Html Msg)
galleryButtonView gal user =
    let
        options =
            { stopPropagation = True
            , preventDefault = False
            }
    in
    if List.length gal > 1 then
        [ div [ class "gal-btn " ]
            [ button [ onWithOptions "click" options (Decode.succeed <| ChangeImage user -1) ] [ icon "fas fa-chevron-left" ]
            , button [ onWithOptions "click" options (Decode.succeed <| ChangeImage user 1) ] [ icon "fas fa-chevron-right" ]
            ]
        ]
    else
        []
