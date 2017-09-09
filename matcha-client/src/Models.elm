module Models exposing (..)

import RemoteData exposing (..)
import Navigation exposing (Location)

type Route
    = Members
    | NotFoundRoute

type alias Model =
    { route : Route
    , users : WebData (List User)
    }

type alias User =
    { fname : String
    , lname : String
    }

type Msg 
    = UsersResponse (WebData (List User))
    | OnLocationChange Location
