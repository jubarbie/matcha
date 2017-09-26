module Msgs exposing (..)

import RemoteData exposing (..) 
import Navigation exposing (..)
import Models exposing (..)

type Msg 
    = UsersResponse (WebData (List User))
    | UserResponse String (WebData (ApiResponse (Maybe User)))
    | LoginResponse (WebData AuthResponse)
    | NewUserResponse (WebData (ApiResponse (Maybe User)))
    | Logout
    | OnLocationChange Location
    | SaveToken (List String) 
    | UpdateNewUserForm String String
    | UpdateLoginForm String String
    | NewUser
    | SendLogin
