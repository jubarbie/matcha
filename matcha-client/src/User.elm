module User exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
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
        [ a [href <| "http://localhost:3000/#/users"][ text "Back" ]
        , h3 [] [ text user.username ] 
        , div [] [ text <| genderToString user.gender ]
        , div [] [ text user.bio ]
        ]
