module User exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Commands exposing (genderToString)
import Msgs exposing (..)


view : Model -> Html Msg
view model =
    case model.current_user of
        Just u -> viewUser u
        _ -> div [][ text <| "user not found" ]

viewUser : User -> Html Msg
viewUser user =
    div []
        [ button [ onClick <| GoBack 1 ][ text "Back" ]
        , h3 [] [ text user.username ]
        , div [] [ text <| genderToString user.gender ]
        , div [] [ text user.bio ]
        ]
