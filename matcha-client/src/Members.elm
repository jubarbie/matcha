module Members exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (..)
import Commands exposing (genderToString)
import Msgs exposing (..)
import List


view : Model -> Html Msg
view model =
    div [] [ viewUsers model.users ]

viewUsers : List User -> Html Msg
viewUsers users =
    div []
        [ h1 [] [ text "Les membres" ]
        , ul [ ] <| List.map (\u -> 
            li [] [ viewUser u ]
            ) users
        ]

viewUser : User -> Html Msg
viewUser user =
    div [ ] 
        [ h3 [] [ text user.username ] 
        , div [] [ text <| genderToString user.gender ]
        , div [] [ a [href <| "http://localhost:3000/#/user/" ++ user.username][ text "See profile" ] ]
        ]
