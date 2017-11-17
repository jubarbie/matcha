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
    | Members
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

type alias Model =
    { route : Route
    , session : Maybe Session
    , loginForm: Form
    , newUserForm : Form
    , editAccountForm : Form
    , resetPwdForm : Form
    , changePwdForm : Form
    , users : List User
    , usersAdmin : List SessionUser
    , current_user : Maybe User
    , current_talk : Maybe Talk
    , message : Maybe String
    , map_state : MapState
    , current_location : Maybe Localisation
    , matchAnim : Maybe Time.Time
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


initialModel : Route -> Model
initialModel route =
    { route = route
    , session = Nothing
    , loginForm =  initLoginForm
    , newUserForm = initFastNewUserForm
    , editAccountForm = []
    , resetPwdForm = initResetPwdForm
    , changePwdForm = initChangePwdForm
    , users = []
    , usersAdmin = []
    , current_user = Nothing
    , current_talk = Nothing
    , message = Nothing
    , map_state = if (route == AccountRoute || route == EditAccountRoute ) then Loading else NoMap
    , current_location = Nothing
    , matchAnim = Nothing
    }
