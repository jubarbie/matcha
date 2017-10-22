module Msgs exposing (..)

import RemoteData exposing (..)
import Navigation exposing (..)
import Models exposing (..)

type Msg
    = UsersResponse (WebData (List User))
    | ProfileResponse String (WebData (ApiResponse (Maybe User)))
    | UserResponse (WebData (ApiResponse (Maybe User)))
    | CurrentUserResponse (WebData (ApiResponse (Maybe CurrentUser)))
    | LoginResponse (WebData AuthResponse)
    | NewUserResponse (WebData (ApiResponse (Maybe User)))
    | DeleteUserResponse String (WebData (ApiResponse (Maybe User)))
    | ToggleLikeResponse String (WebData (ApiResponse (Maybe User)))
    | GetTalkResponse (WebData (ApiResponse (Maybe (List Message))))
    | GetTalksResponse (WebData (ApiResponse (Maybe (List String))))
    | Logout
    | OnLocationChange Location
    | SaveToken (List String)
    | UpdateNewUserForm String String
    | UpdateLoginForm String String
    | NewUser
    | SendLogin
    | DeleteUser String
    | Localize
    | GoBack Int
    | ToggleLike String
