module Msgs exposing (..)

import Api.ApiModel exposing (..)
import App.Talk.TalkModel exposing (..)
import App.User.UserModel exposing (..)
import Http
import Models exposing (..)
import Navigation exposing (..)
import Ports exposing (ImagePortData)
import RemoteData exposing (..)
import Time


type Msg
    = NoOp
    | UsersResponse (Result Http.Error (ApiResponse (Maybe (List User))))
    | SearchResponse (Result Http.Error (ApiResponse (Maybe (List User))))
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
    | UpdateFieldResponse (Result Http.Error (ApiResponse (Maybe SessionUser)))
    | SearchTagResponse (Result Http.Error (ApiResponse (Maybe (List String))))
    | ReqTagResponse (Result Http.Error (ApiResponse (Maybe (List String))))
    | NoDataApiResponse (Result Http.Error (ApiResponse (Maybe String)))
    | Logout
    | ShowUser String
    | UnshowAll
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
    | GetIpLocalisationResponse (WebData LocalisationApi)
    | Localize
    | UpdateEditAccountForm String String
    | SaveAccountUpdates
    | UpdateAnim Time.Time
    | ResetPwd
    | ChangePwd
    | UpdateGender Gender
    | UpdateIntIn Gender
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
    | ToggleEmoList
    | AddEmo String String
    | UpdateTagFilter String
    | UpdateMinAgeFilter String
    | UpdateMaxAgeFilter String
    | UpdateLocFilter String
    | ToggleAdvanceFilters
    | ToggleTalksList
    | ResetFilters
    | SetCurrentTalk String
    | CloseCurrentTalk
    | ReportUser String
    | BlockUser String
    | AdvanceSearch
    | UpdateSearchLogin String
    | UpdateSearchTags String
    | UpdateMinYearSearch String
    | UpdateMaxYearSearch String
    | UpdateLocSearch String
    | ResetSearch
    | UpdateBirth String
    | ToggleAccountForm
    | ToggleResetPwdForm
