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
  div [] <|
      [ h1 [] [text "Account"]
      , div [] <|
        (if user.status ==  Incomplete then
          [ div [] [ text "Please complete your profile" ] ]
        else
          []) ++
        (if user.status ==  ResetPassword then
          [ div [] [ text "Don't forget to change your password" ] ]
        else
          [])
      , h2 [] [text "Infos"]
      , div [] [text user.username]
      , div [] [text user.fname, text " ",text user.lname]
      , div [] [text user.email]
      , div [] [text user.bio]
      , a [ href "/#/edit_account" ] [ text "Edit infos" ]
      , br [] []
      , a [ href "/#/edit_password" ] [ text "Change password" ]
      ] ++
      (if List.length user.photos > 0 then
         [ hr [] []
         , h2 [] [ text "Fotos"]
         , div [] <| List.map (\s -> img [ src s ] [] ) user.photos
         ]
      else [])
      ++
      [ hr [] []
      , h2 [] [text "Localisation"]
      , div [ id "map" ] []
      , button [ onClick SaveLocation ][ text "Use this location" ]
      , button [ onClick Localize ][ text "Localize me" ]
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
          , div []
            [ label [ for "male" ] [ text "Male" ]
            , input [ name "gender", type_ "radio", id "male" ] []
            , label [ for "female" ] [ text "Female" ]
            , input [ name "gender", type_ "radio", id "female" ] []
            ]
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
