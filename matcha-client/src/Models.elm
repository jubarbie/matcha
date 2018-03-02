module Models exposing (..)

import FormUtils exposing (..)
import Time exposing (..)
import User.UserModel exposing (..)
import Talk.TalkModel exposing (..)
import Notif.NotifModel exposing (..)
import Api.ApiModel exposing (..)


type AppRoutes
    = UsersRoute String
    | UserRoute String
    | TalksRoute
    | TalkRoute String
    | AccountRoute
    | EditAccountRoute
    | ChangePwdRoute
    | NotFoundAppRoute


type LoginRoutes
    = LoginRoute
    | SigninRoute
    | ResetPwdRoute
    | NotFoundLoginRoute


type MapState
    = NoMap
    | Loading
    | Rendered


type alias Image =
    { contents : String
    , filename : String
    }

type alias LoginModel =
  { loginForm : Form
  , newUserForm : Form
  , resetPwdForm : Form
  , message : Maybe String
  }

type alias AppModel =
  { editAccountForm : Form
  , changePwdForm : Form
  , tagInput : String
  , searchTag : List String
  , users : Users
  , talks : List Talk
  , notifVisit: Int
  , notifLike: Int
  , userFilter : List FilterUsers
  , userSort : SortUsers
  , orderSort : OrderSort
  , message : Maybe String
  , map_state : MapState
  , current_location : Maybe Localisation
  , matchAnim : Maybe Time.Time
  , idImg : String
  , mImage : Maybe Image
  , currentTime : Maybe Time.Time
  , showAccountMenu : Bool
  , showAdvanceFilters : Bool
  , showEmoList : Bool
  }

type Model
  = NotConnected LoginRoutes LoginModel
  | Connexion AppRoutes
  | Connected AppRoutes Session AppModel

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

initialModel : LoginRoutes -> Model
initialModel route =
  NotConnected route initialLoginModel

initialLoginModel : LoginModel
initialLoginModel =
  { loginForm = initLoginForm
  , newUserForm = initNewUserForm
  , resetPwdForm = initResetPwdForm
  , message = Nothing
  }

initialAppModel : AppModel
initialAppModel =
    { editAccountForm = []
    , changePwdForm = initChangePwdForm
    , tagInput = ""
    , searchTag = []
    , users = []
    , talks = []
    , notifVisit = 0
    , notifLike = 0
    , userFilter = []
    , userSort = S_Afin
    , orderSort = DESC
    , message = Nothing
    , map_state = NoMap
    , current_location = Nothing
    , matchAnim = Nothing
    , idImg = "ImageInputId"
    , mImage = Nothing
    , currentTime = Nothing
    , showAccountMenu = False
    , showAdvanceFilters = False
    , showEmoList = False
    }
