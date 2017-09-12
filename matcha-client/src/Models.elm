module Models exposing (..)

import RemoteData exposing (..)
import Navigation exposing (Location)

type Route
    = Login
    | Members
    | Chat
    | Account
    | NotFoundRoute

type alias Model =
    { route : Route
    , loginInput : Input String
    , passwordInput : Input String
    , users : List User
    , message : Maybe String
    }


type alias Input a = { input : String, value : a, validation : (Bool, String) }

type alias ApiResponse =
    { status : String
    , message : Maybe String 
    }

type alias User =
    { fname : String
    , lname : String
    }

type Msg 
    = UsersResponse (WebData (List User))
    | HttpResponse (WebData ApiResponse)
    | OnLocationChange Location
    | UpdateLoginInput String
    | UpdatePasswordInput String
    | SendLogin
