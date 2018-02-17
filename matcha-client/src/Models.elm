module Models exposing (..)

import FormUtils exposing (..)
import Time exposing (..)
import User.UserModel exposing (..)
import Talk.TalkModel exposing (..)
import Notif.NotifModel exposing (..)
import Api.ApiModel exposing (..)


type Route
    = Connect LoginRoute
    | UsersRoute String
    | UserRoute String
    | TalksRoute
    | TalkRoute String
    | AccountRoute
    | EditAccountRoute
    | NotFoundRoute
    | ChangePwdRoute


type LoginRoute
    = Login
    | Signin
    | ResetPwdRoute


type MapState
    = NoMap
    | Loading
    | Rendered


type alias Image =
    { contents : String
    , filename : String
    }

type alias Model =
    { route : Route
    , session : Maybe Session
    , loginForm : Form
    , newUserForm : Form
    , editAccountForm : Form
    , resetPwdForm : Form
    , changePwdForm : Form
    , tagInput : String
    , searchTag : List String
    , users : Users
    , talks : List Talk
    , notifVisit: Int
    , notifLike: Int
    , userFilter : Maybe FilterUsers
    , userSort : SortUsers
    , orderSort : OrderSort
    , usersAdmin : List SessionUser
    , message : Maybe String
    , map_state : MapState
    , current_location : Maybe Localisation
    , matchAnim : Maybe Time.Time
    , idImg : String
    , mImage : Maybe Image
    , currentTime : Maybe Time.Time
    , showAccountMenu : Bool
    , showEmoList : Bool
    }


type alias Session =
    { user : SessionUser
    , token : String
    }


type alias AuthResponse =
    { status : String
    , message : Maybe String
    , token : Maybe String
    , user : Maybe SessionUser
    }


initialModel : Route -> Model
initialModel route =
    { route = route
    , session = Nothing
    , loginForm = initLoginForm
    , newUserForm = initFastNewUserForm
    , editAccountForm = []
    , resetPwdForm = initResetPwdForm
    , changePwdForm = initChangePwdForm
    , tagInput = ""
    , searchTag = []
    , users = []
    , talks = []
    , notifVisit = 0
    , notifLike = 0
    , userFilter = Nothing
    , userSort = S_Afin
    , orderSort = DESC
    , usersAdmin = []
    , message = Nothing
    , map_state =
        if route == AccountRoute || route == EditAccountRoute then
            Loading
        else
            NoMap
    , current_location = Nothing
    , matchAnim = Nothing
    , idImg = "ImageInputId"
    , mImage = Nothing
    , currentTime = Nothing
    , showAccountMenu = False
    , showEmoList = False
    }
