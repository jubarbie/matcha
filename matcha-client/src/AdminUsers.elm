module AdminUsers exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import List
import UserModel exposing (..)


view : Model -> Html Msg
view model =
    div [] [ viewUsers model.usersAdmin ]

viewUsers : List SessionUser -> Html Msg
viewUsers users =
    div []
        [ h1 [] [ text "Members" ]
        , table [ class "u-full-width" ] <|
          [ thead []
             [ tr []
                  [ th [] [ text "Username" ]
                  , th [] [ text "First name" ]
                  , th [] [ text "Last name" ]
                  , th [] [ text "Email" ]
                  , th [] [ text "Gender" ]
                  ]
            ]
          , tbody [] <| List.map (\u -> viewUserRow u ) users
          ]
          ]

viewUserRow : SessionUser -> Html Msg
viewUserRow user =
    tr [ ]
        [ td [] [ text user.username ]
        , td [] [ text user.fname ]
        , td [] [ text user.lname ]
        , td [] [ text user.email ]
        , td [] [ text <| genderToString user.gender ]
        , td [] [ a [href <| "http://localhost:3000/#/user/" ++ user.username][ text "See" ] ]
        , td [] [ button [ onClick <| DeleteUser user.username ][ text "Del" ]]
        ]
