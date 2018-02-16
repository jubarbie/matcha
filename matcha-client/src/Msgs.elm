module Msgs exposing (..)

import Api.ApiModel exposing (..)
import Http
import Models exposing (..)
import Navigation exposing (..)
import Ports exposing (ImagePortData)
import RemoteData exposing (..)
import Talk.TalkModel exposing (..)
import Time
import User.UserModel exposing (..)


type Msg
    = NoOp
    | UsersResponse (Result Http.Error (ApiResponse (Maybe (List User))))
    | UsersAdminResponse (WebData (ApiResponse (Maybe (List SessionUser))))
    | SessionUserResponse String (Result Http.Error (ApiResponse (Maybe SessionUser)))
    | UserResponse (Result Http.Error (ApiResponse (Maybe User)))
    | LoginResponse (WebData AuthResponse)
    | NewUserResponse (WebData (ApiResponse (Maybe User)))
    | GetTalkResponse (Result Http.Error (ApiResponse (Maybe Talk)))
    | GetTalksResponse (Result Http.Error (ApiResponse (Maybe (List Talk))))
    | SaveLocRespone (Result Http.Error (ApiResponse (Maybe String)))
    | EditAccountResponse String String String String (Result Http.Error (ApiResponse (Maybe User)))
    | ResetPwdResponse (WebData (ApiResponse (Maybe String)))
    | ChangePwdRespone (Result Http.Error (ApiResponse (Maybe String)))
    | UpdateFieldResponse String (Result Http.Error (ApiResponse (Maybe SessionUser)))
    | SearchTagResponse (Result Http.Error (ApiResponse (Maybe (List String))))
    | ReqTagResponse (Result Http.Error (ApiResponse (Maybe (List String))))
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
    | GoBack Int
    | ToggleLike String
    | ToggleAccountMenu
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
    | Notification String
    | ChangeImage User Int
    | GoTo String
    | ChangeSort SortUsers
