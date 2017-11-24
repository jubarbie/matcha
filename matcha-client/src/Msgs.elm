module Msgs exposing (..)

import RemoteData exposing (..)
import Navigation exposing (..)
import Models exposing (..)
import UserModel exposing (..)
import Time
import Ports exposing (ImagePortData)

type Msg
    = UsersResponse (WebData (ApiResponse (Maybe (List User))))
    | UsersAdminResponse (WebData (ApiResponse (Maybe (List SessionUser))))
    | SessionUserResponse String (WebData (ApiResponse (Maybe SessionUser)))
    | UserResponse (WebData (ApiResponse (Maybe User)))
    | LoginResponse (WebData AuthResponse)
    | NewUserResponse (WebData (ApiResponse (Maybe User)))
    | DeleteUserResponse String (WebData (ApiResponse (Maybe User)))
    | ToggleLikeResponse String (WebData (ApiResponse (Maybe MatchStatus)))
    | GetTalkResponse (WebData (ApiResponse (Maybe (List Message))))
    | GetTalksResponse (WebData (ApiResponse (Maybe (List String))))
    | NewMessageResponse (WebData (ApiResponse (Maybe Talk)))
    | SaveLocRespone (WebData (ApiResponse (Maybe String)))
    | EditAccountResponse String String String String (WebData (ApiResponse (Maybe User)))
    | ResetPwdResponse (WebData (ApiResponse (Maybe String)))
    | ChangePwdRespone (WebData (ApiResponse (Maybe String)))
    | UpdateFieldResponse String (WebData (ApiResponse (Maybe SessionUser)))
    | SearchTagResponse (WebData (ApiResponse (Maybe (List String))))
    | ReqTagResponse (WebData (ApiResponse (Maybe (List String))))
    | Logout
    | OnLocationChange Location
    | SaveToken (List String)
    | SetNewLocalisation (List Float)
    | UpdateNewUserForm String String
    | UpdateLoginForm String String
    | UpdateResetPwdForm String String
    | UpdateEditPwdForm String String
    | NewUser
    | SendLogin
    | DeleteUser String
    | SaveLocation
    | GoBack Int
    | ToggleLike String
    | UpdateNewMessage String
    | SendNewMessage
    | NewMessage String
    | FetchTalk String Time.Time
    | LoadMap Time.Time
    | GetIpLocalisation (WebData LocalisationApi)
    | Localize
    | UpdateEditAccountForm String String
    | SaveAccountUpdates
    | UpdateAnim Time.Time
    | ResetPwd
    | ChangePwd
    | UpdateGender Gender
    | UpdateIntIn (List Gender)
    | SearchTag String
    | AddTag String
    | AddNewTag
    | RemoveTag String
    | ImageSelected
    | ImageRead ImagePortData
    | DeleteImg Int
    | SetCurrentTime (Maybe Time.Time)
    | UpdateCurrentTime Time.Time
