module Account exposing (view, viewEditAccount, viewChangePwd)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed exposing (..)
import Models exposing (..)
import Commands exposing (..)
import Msgs exposing (..)
import FormUtils exposing (..)
import UserModel exposing (..)


view : Model ->  Html Msg
view model =
    case model.session of
        Just s -> Html.Keyed.node "accnt" [] [("div", viewAccount model s.user)]
        _ -> text "no session..."

viewAccount : Model -> SessionUser -> Html Msg
viewAccount model user =
  div []
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
          , div [] [text <| genderToString user.gender]
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
              div [ class "tag" ]
                  [ text t
                  , div [ class "del", onClick <| RemoveTag t ][ text "x"]
                  ]) user.tags
          , viewTagForm model
          ]
      ]
    , div [class "row"]
      [  hr [][]
        , h2 [] [ text "Photos" ]
        , (if List.length user.photos > 0 then
           div [] <| List.map (\s -> img [ src s ] [] ) user.photos
           else div [] [ text "You haven't uploaded any pictures yet"] )
      ]
    , div [class "row"]
          [ hr [] []
          , h2 [] [text "Localisation"]
          , div [ id "map" ] []
          , button [ onClick SaveLocation ][ text "Use this location" ]
          , button [ onClick Localize ][ text "Localize me" ]
          ]
      ]

viewTagForm : Model -> Html Msg
viewTagForm model =
  div [ class "input" ]
    [ input [ type_ "text", onInput SearchTag ] []
    , div []
      [ Html.ul [] <|
        List.map (\i -> li [ onClick <| AddTag i ] [ text i ]) model.searchTag
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
        div []
          [ viewEditAccountForm model.editAccountForm
          ]

viewGenderForm : Maybe Gender -> Html Msg
viewGenderForm gender =
  div []
    [ label [ for "male" ] [ text "Male" ]
      , input
          [ name "gender"
          , type_ "radio"
          , id "male"
          , onClick <| UpdateGender M
          , checked (gender == Just M)
          ] []
      , label [ for "female" ] [ text "Female" ]
      , input
          [ name "gender"
          , type_ "radio"
          , id "female"
          , onClick <| UpdateGender F
          , checked (gender == Just F)
          ] []
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
    div []
      [ label [ for "male" ] [ text "Male" ]
        , input
            [ name "intIn"
            , type_ "checkbox"
            , id "male"
            , onClick <| UpdateIntIn (getGenderList M)
            , checked <| List.member M intIn
            ] []
        , label [ for "female" ] [ text "Female" ]
        , input
            [ name "intIn"
            , type_ "checkbox"
            , id "female"
            , onClick <| UpdateIntIn (getGenderList F)
            , checked <| List.member F intIn
            ] []
        ]

viewEditAccountForm : Form -> Html Msg
viewEditAccountForm accountForm =
  div []
    [ h1 [] [ text <| "Edit account" ]
    , div [] <| List.map (\i -> viewInput (UpdateEditAccountForm i.id) i) accountForm
      ++ [ div [ onClick SaveAccountUpdates, class "important-font" ][ text "SAVE" ]
         , a [ href "/#/account" ][ text "Cancel" ]
         ]
    ]

viewEditPwdForm : Form -> Html Msg
viewEditPwdForm formm =
  div []
    [ h1 [] [ text <| "Edit password" ]
    , div [] <| List.map (\i -> viewInput (UpdateEditPwdForm i.id) i) formm
      ++ [ div [ onClick ChangePwd, class "important-font" ][ text "CHANGE PASSWORD" ]
         , a [ href "/#/account" ][ text "Cancel" ]
         ]
    ]
