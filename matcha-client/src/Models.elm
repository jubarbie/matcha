module Models exposing (..)

import RemoteData exposing (..)
import Navigation exposing (Location)

type Route
    = Connect LoginRoute
    | Members
    | Chat
    | Account
    | NotFoundRoute

type LoginRoute
    = Login
    | Signin

type alias Model =
    { route : Route
    , token : Maybe String
    , loginInput : Input String
    , passwordInput : Input String
    , users : List User
    , message : Maybe String
    }


type alias Input a = { input : String, value : a, validation : (Bool, String) }

type alias AuthResponse =
    { status : String
    , message : Maybe String
    , token : Maybe String
    }

type alias ApiResponse =
    { status : String
    , message : Maybe String
    }

type alias User =
    { fname : String
    , lname : String
    , email : String
    , gender : Gender
    , intIn : List Gender
    , bio : String
    }

type Gender 
    = M
    | F

type alias NewUserForm =
    { username : Input String
    , email : Input String
    , password : Input String
    , rePassword : Input String
    , gender : Input Gender
    , intIn : Input (List Gender)
    , bio : Input String
    }

type Msg 
    = UsersResponse (WebData (List User))
    | LoginResponse (WebData AuthResponse)
    | Logout
    | OnLocationChange Location
    | SaveToken String 
    | UpdateLoginInput String
    | UpdatePasswordInput String
    | SendLogin
