module Models exposing (..)


type Route
    = Connect LoginRoute
    | Members
    | Chat
    | Account
    | NotFoundRoute

type LoginRoute
    = Login
    | Signin

type alias Model =
    { route : Route
    , session : Maybe Session
    , loginForm: LoginForm
    , newUserForm : NewUserForm
    , users : List User
    , message : Maybe String
    }

type alias Session =
    { username : String
    , token : String
    }


type alias Input a =
    { input : String
    , validation : ValidationForm a 
    , id : String
    , label : String
    }

type ValidationForm a
    = Waiting
    | Valid a
    | NotValid String


type alias AuthResponse =
    { status : String
    , message : Maybe String
    , token : Maybe String
    }

type alias ApiResponse =
    { status : String
    , message : Maybe String
    }

type alias User =
    { fname : String
    , lname : String
    , email : String
    , gender : Gender
    , intIn : Gender
    , bio : String
    }

type Gender 
    = M
    | F

type alias LoginForm =
    { login : Input String
    , password : Input String
    }

initInput : Input a
initInput =
    Input "" Waiting "" ""

initLoginForm : LoginForm
initLoginForm = 
    LoginForm initInput initInput

initNewUserForm : NewUserForm
initNewUserForm = 
    NewUserForm initInput initInput initInput initInput initInput initInput initInput initInput initInput

type alias NewUserForm =
    { username : Input String
    , fname : Input String
    , lname : Input String
    , email : Input String
    , password : Input String
    , rePassword : Input String
    , gender : Input Gender
    , intIn : Input Gender
    , bio : Input String
    }

initialModel : Route -> Model
initialModel route =
    { route = route
    , session = Nothing
    , loginForm =  initLoginForm
    , newUserForm = initNewUserForm
    , users = []
    , message = Nothing
    }
