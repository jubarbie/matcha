module Models exposing (..)

import RemoteData exposing (..)
import Navigation exposing (Location)

type Route
    = Login
    | Members
    | NotFoundRoute

type alias Model =
    { route : Route
    , loginInput : Input String
    , passwordInput : Input String
    , users : WebData (List User)
    }


type alias Input a = { input : String, value : a, validation : (Bool, String) }

type alias User =
    { fname : String
    , lname : String
    }

type Msg 
    = UsersResponse (WebData (List User))
    | OnLocationChange Location
    | UpdateInput String
    | SendLogin
