module Msgs exposing (..)

import RemoteData exposing (..) 
import Navigation exposing (..)
import Models exposing (..)

type Msg 
    = UsersResponse (WebData (List User))
    | LoginResponse (WebData AuthResponse)
    | HandleApiResponse (WebData ApiResponse)
    | Logout
    | OnLocationChange Location
    | SaveToken (List String) 
    | UpdateNewUserForm String String
    | UpdateLoginForm String String
    | NewUser
    | SendLogin
