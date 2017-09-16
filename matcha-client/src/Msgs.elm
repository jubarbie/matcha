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
    | UpdateLoginInput String
    | UpdatePasswordInput String
    | UpdateUsernameInput String
    | UpdateFnameInput String
    | UpdateLnameInput String
    | UpdateEmailInput String
    | UpdatePwdInput String
    | UpdateRePwdInput String
    | UpdateGenderInput String
    | UpdateIntInInput String
    | UpdateBioInput String
    | NewUser
    | SendLogin
