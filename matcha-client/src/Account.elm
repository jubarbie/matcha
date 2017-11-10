module Account exposing (view, viewEditAccount)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed exposing (..)
import Login exposing (viewInput)
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

viewAccount : Model -> User -> Html Msg
viewAccount model user =
  div []
      [ h1 [] [text "Account"]
      , h2 [] [text "Infos"]
      , div [] [text user.username]
      , div [] [text user.fname, text " ",text user.lname]
      , div [] [text user.email]
      , div [] [text user.bio]
      , a [ href "/#/edit_account" ] [ text "Edit infos" ]
      , hr [] []
      , h2 [] [ text "Fotos"]
      , div [] <| List.map (\s -> img [ src s ] [] ) user.photos
      , hr [] []
      , h2 [] [text "Localisation"]
      , div [ id "map" ] []
      , button [ onClick SaveLocation ][ text "Use this location" ]
      , button [ onClick Localize ][ text "Localize me" ]
      ]


viewEditAccount : Model -> Html Msg
viewEditAccount model =
    case model.session of
        Just s -> viewEditAccountForm model.editAccountForm
        _ -> text "no session..."

viewEditAccountForm : Form -> Html Msg
viewEditAccountForm accountForm =
  div []
    [ h1 [] [ text <| "Edit account" ]
    , div [] <| List.map (\i -> viewInput (UpdateEditAccountForm i.id) i) accountForm
      ++ [ div [ onClick SaveAccountUpdates, class "important-font" ][ text "SAVE" ]
         , a [ href "/#/account" ][ text "Cancel" ]
         ]
    ]
