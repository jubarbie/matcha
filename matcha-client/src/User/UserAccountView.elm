module User.UserAccountView exposing (view, viewEditAccount, viewChangePwd)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed exposing (..)
import Json.Decode as JD
import Models exposing (..)
import Commands exposing (..)
import Msgs exposing (..)
import FormUtils exposing (..)
import User.UserModel exposing (..)
import Utils exposing (..)


view : Model ->  Html Msg
view model =
    case model.session of
        Just s -> Html.Keyed.node "accnt" [] [("div", viewAccount model s.user)]
        _ -> text "no session..."

viewAccount : Model -> SessionUser -> Html Msg
viewAccount model user =
  div [class "content"]
    [ div [ class "row" ]
      [ div [class "twelve columns"] <|
        [ div [] <|
          (if user.status ==  Incomplete then
            [ div [] [ text "Please complete your profile" ] ]
          else
            []) ++
          (if user.status ==  ResetPassword then
            [ div [] [ text "Don't forget to change your password" ] ]
          else
            [])
        ]
      ]
    , div [ class "row"]
      [ div [class "six columns"]
          [ h2 [] [text "Infos"]
          , div [] [text user.username]
          , div [] [text user.fname, text " ",text user.lname]
          , div [] [text user.email]
          , div [] [text user.bio]
          , a [ href "/#/edit_account" ] [ text "Edit infos" ]
          , br [] []
          , a [ href "/#/edit_password" ] [ text "Change password" ]
          ]
      , div [ class "six columns"]
          [ h2 [][text "Interest"]
          , viewGenderForm user.gender
          , viewIntInForm user.intIn
          , div [] <| List.map (\t ->
              div [ class "tag dismissable" ]
                  [ text t
                  , div [ class "del pointer", onClick <| RemoveTag t ][ icon "fas fa-times" ]
                  ]) (List.sort user.tags)
          , viewTagForm model
          ]
      ]
    , div [class "row"]
      [  hr [][]
        , h2 [] [ text "Photos" ]
        , (if List.length user.photos > 0 then
           div [] <| List.map (\(id_, s) ->
             div [ style [("background", "url(" ++ s ++ ") center center no-repeat")], class "img-box" ]
                  [ button [ class "del", onClick <| DeleteImg id_ ] [ icon "fas fa-times" ]
                  ]
            ) user.photos
           else div [] [ text "You haven't uploaded any pictures yet"] )
      , (if (List.length user.photos) < 5 then
         viewNewImgeForm model
        else
          div [][])
      ]
    , div [class "row"]
          [ hr [] []
          , h2 [] [text "Localisation"]
          , div [ id "map" ] []
          , button [ onClick SaveLocation ][ text "Use this location" ]
          , button [ onClick Localize ][ text "Localize me" ]
          ]
      ]

viewNewImgeForm : Model -> Html Msg
viewNewImgeForm model =
    let
        imagePreview =
            case model.mImage of
                Just i ->
                    viewImagePreview i

                Nothing ->
                    text ""
    in
        div [ class "imageWrapper" ]
            [ label [ for model.idImg, class "label-upload button" ]
              [ input
                [ type_ "file"
                , accept "image/*"
                , id model.idImg
                , on "change"
                    (JD.succeed ImageSelected)
                ]
                []
                , text "Upload new image"
              ]
            ]


viewImagePreview : Image -> Html Msg
viewImagePreview image =
    img
        [ src image.contents
        , title image.filename
        ]
        []

viewTagForm : Model -> Html Msg
viewTagForm model =
  div [ class "input" ]
    [ input [ type_ "text", onInput SearchTag ] []
    , button [ onClick AddNewTag ] [ text "Add" ]
    , div []
      [ Html.ul [ class "search-list" ] <|
        List.map (\i -> li [ onClick <| AddTag i, class "pointer" ] [ text i ]) model.searchTag
      ]
    ]

viewChangePwd : Model -> Html Msg
viewChangePwd model =
    case model.session of
      Nothing -> text "no session..."
      Just s -> viewEditPwdForm model.changePwdForm



viewEditAccount : Model -> Html Msg
viewEditAccount model =
    case model.session of
      Nothing -> text "no session..."
      Just s ->
        div [class "content"]
          [ viewEditAccountForm model.editAccountForm
          ]

viewGenderForm : Maybe Gender -> Html Msg
viewGenderForm gender =
  div [ class "row" ]
    [ label [ for "male", class "six columns" ]
            [ i [class "fas fa-mars"] []
            , input
                [ name "gender"
                , type_ "radio"
                , id "male"
                , onClick <| UpdateGender M
                , checked (gender == Just M)
                ] []
            ]
      , label [ for "female", class "six columns" ]
              [ i [class "fas fa-venus"] []
              , input
                  [ name "gender"
                  , type_ "radio"
                  , id "female"
                  , onClick <| UpdateGender F
                  , checked (gender == Just F)
                  ] []
              ]
      ]

viewIntInForm : List Gender -> Html Msg
viewIntInForm intIn =
  let
    getGenderList a =
      if List.member a intIn then
        List.filter ((/=) a) intIn
      else
        a :: intIn
  in
    div [ class "row"]
      [ label [ for "male", class "six columns" ]
              [ i [class "fas fa-mars"] []
              , input
                  [ name "intIn"
                  , type_ "checkbox"
                  , id "male"
                  , onClick <| UpdateIntIn (getGenderList M)
                  , checked <| List.member M intIn
                  ] []
              ]
        , label [ for "female", class "six columns" ]
                [ i [class "fas fa-venus"] []
                , input
                    [ name "intIn"
                    , type_ "checkbox"
                    , id "female"
                    , onClick <| UpdateIntIn (getGenderList F)
                    , checked <| List.member F intIn
                    ] []
                ]
        ]

viewEditAccountForm : Form -> Html Msg
viewEditAccountForm accountForm =
  div []
    [ h1 [] [ text <| "Edit account" ]
    , Html.form [] <| List.map (\i -> viewInput (UpdateEditAccountForm i.id) i) accountForm
      ++ [ input
              [ onWithOptions
                  "click"
                  { preventDefault = True
                  , stopPropagation = False
                  }
                  (JD.succeed SaveAccountUpdates)
              , class "important-font"
              , type_ "submit"
              , value "SAVE"
              ]
              []
         , a [ href "/#/account" ][ text "Cancel" ]
         ]
    ]

viewEditPwdForm : Form -> Html Msg
viewEditPwdForm formm =
  div [class "content"]
    [ h1 [] [ text <| "Edit password" ]
    , Html.form [] <| List.map (\i -> viewInput (UpdateEditPwdForm i.id) i) formm
      ++ [ input
              [ onWithOptions
                  "click"
                  { preventDefault = True
                  , stopPropagation = False
                  }
                  (JD.succeed ChangePwd)
              , class "important-font"
              , type_ "submit"
              , value "CHANGE PASSWORD"
              ]
              []
         , a [ href "/#/account" ][ text "Cancel" ]
         ]
    ]
