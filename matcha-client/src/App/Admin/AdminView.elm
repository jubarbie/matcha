module App.Admin.AdminView exposing (..)

import App.Admin.AdminModel exposing (..)
import App.User.UserModel exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msgs exposing (..)
import Utils exposing (..)

view : AdminModel -> Html Msg
view model  =
    div [ class "container" ]
        [ h1 [] [ text "ADMIN" ]
        , viewButtons model
        , if model.fetching then
            div [][ text "fetching users..." ]
          else
            viewUsersList model
        ]

getUsers : AdminUsers -> List SessionUser
getUsers u =
  case u of
    All a -> a
    Reported a -> a

viewButtons : AdminModel -> Html Msg
viewButtons model =
  case model.users of
    All a -> div []
          [ button [ onClick ReportedUsers ][ text "Reported" ]
          , button [ onClick NextPage ][ text "Next" ]
          ]
    Reported a -> div []
          [ button [ onClick AllUsers ][ text "All" ]
          ]

viewUsersList : AdminModel -> Html Msg
viewUsersList model =
  table [ class "u-full-width" ] <|
        [ tr []
            [ th [] [text "Login"]
            , th [] [text "Fist Name"]
            , th [] [text "Last Name"]
            , th [] []
            ]
        ] ++
          List.map (\u -> tr []  [ th [] [ text u.username ]
                                    , th [] [ text u.fname ]
                                    , th [] [ text u.lname ]
                                    , th [] [ button [onClick <| DeleteUser u.username] [icon "fas fa-trash"]]
                                    ]
                      ) (getUsers model.users)
