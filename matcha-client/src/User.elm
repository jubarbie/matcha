module User exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (..)
import Commands exposing (genderToString)
import Msgs exposing (..)
import List


view : Model -> Html Msg
view model =
    case model.current_user of
        Just u -> viewUser u
        _ -> div [][ text <| "user not found" ]

viewUser : User -> Html Msg
viewUser user =
    div [ class "user-box" ] 
        [ h3 [] [ text user.username ] 
        , text <| genderToString user.gender
        , a [href <| "http://localhost:3000/#/user/" ++ user.username][ text "See profile" ]
        ]
