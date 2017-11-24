module Models exposing (..)

import UserModel exposing (..)
import FormUtils exposing (..)
import Time exposing (..)

type Route
    = Connect LoginRoute
    | UsersRoute
    | UserRoute String
    | ChatsRoute
    | ChatRoute String
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
    , loginForm: Form
    , newUserForm : Form
    , editAccountForm : Form
    , resetPwdForm : Form
    , changePwdForm : Form
    , tagInput : String
    , searchTag : List String
    , users : List User
    , usersAdmin : List SessionUser
    , current_user : Maybe User
    , current_talk : Maybe Talk
    , message : Maybe String
    , map_state : MapState
    , current_location : Maybe Localisation
    , matchAnim : Maybe Time.Time
    , idImg : String
    , mImage : Maybe Image
    , currentTime : Maybe Time.Time
    }

type alias Talk =
  { messages : List Message
  , username_with : String
  , new_message : String
  }

type alias Message =
  { date : String
  , message : String
  , user : String
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

type alias ApiResponse a =
    { status : String
    , message : Maybe String
    , data : a
    }

type FilterUsers
  = F_Visitors
  | F_Liked

type SortUsers
  = S_Age
  | S_LastOn

initialModel : Route -> Model
initialModel route =
    { route = route
    , session = Nothing
    , loginForm =  initLoginForm
    , newUserForm = initFastNewUserForm
    , editAccountForm = []
    , resetPwdForm = initResetPwdForm
    , changePwdForm = initChangePwdForm
    , tagInput = ""
    , searchTag = []
    , users = []
    , usersAdmin = []
    , current_user = Nothing
    , current_talk = Nothing
    , message = Nothing
    , map_state = if (route == AccountRoute || route == EditAccountRoute ) then Loading else NoMap
    , current_location = Nothing
    , matchAnim = Nothing
    , idImg = "ImageInputId"
    , mImage = Nothing
    , currentTime = Nothing
    }
