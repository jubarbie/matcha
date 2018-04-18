module App.AppModels exposing (..)

import Api.ApiModel exposing (..)
import App.Notif.NotifModel exposing (..)
import App.Talk.TalkModel exposing (..)
import App.User.UserModel exposing (..)
import FormUtils exposing (..)
import Login.LoginModels exposing (..)
import Time exposing (..)


type AppRoutes
    = UsersRoute String
    | SearchRoute
    | NotFoundAppRoute


type MapState
    = NoMap
    | Loading
    | Rendered


type alias Image =
    { contents : String
    , filename : String
    }


type alias AppModel =
    { editAccountForm : Form
    , changePwdForm : Form
    , tagInput : String
    , searchTag : List String
    , notifVisit : List String
    , notifLike : List String
    , notifUnlike : List String
    , message : Maybe String
    , map_state : MapState
    , current_location : Maybe Localisation
    , matchAnim : Maybe Time.Time
    , idImg : String
    , mImage : Maybe Image
    , currentTime : Maybe Time.Time
    , showTalksList : Bool
    , showAccountMenu : Bool
    , showAdvanceFilters : Bool
    , showEmoList : Bool
    , search : SearchModel
    , showEditAccountForm : Bool
    , showResetPwdForm : Bool
    , localizing : Bool
    , fetching : Bool
    }


type alias Session =
    { user : SessionUser
    , token : String
    }


type alias SearchModel =
    { login : String
    , tags : List String
    , yearMin : Maybe Int
    , yearMax : Maybe Int
    , loc : Maybe Int
    }


initialAppModel : AppModel
initialAppModel =
    { editAccountForm = []
    , changePwdForm = initChangePwdForm
    , tagInput = ""
    , searchTag = []
    , notifVisit = []
    , notifLike = []
    , notifUnlike = []
    , message = Nothing
    , map_state = NoMap
    , current_location = Nothing
    , matchAnim = Nothing
    , idImg = "ImageInputId"
    , mImage = Nothing
    , currentTime = Nothing
    , showTalksList = False
    , showAccountMenu = False
    , showAdvanceFilters = False
    , showEmoList = False
    , search = initialSearchModel
    , showEditAccountForm = False
    , showResetPwdForm = False
    , localizing = False
    , fetching = False
    }


initialSearchModel : SearchModel
initialSearchModel =
    { login = ""
    , tags = []
    , yearMin = Nothing
    , yearMax = Nothing
    , loc = Nothing
    }
