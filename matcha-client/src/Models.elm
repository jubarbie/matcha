module Models exposing (..)

import Regex exposing (..)


type Route
    = Connect LoginRoute
    | UsersRoute
    | UserRoute String
    | ChatsRoute
    | ChatRoute String
    | Account
    | Members
    | NotFoundRoute

type LoginRoute
    = Login
    | Signin

type MapState
  = NoMap
  | Loading
  | Rendered

type alias LocalisationApi =
  { status: String
  , lon: Maybe Float
  , lat: Maybe Float
  }

type alias Localisation =
  { lon: Float
  , lat: Float
  }

type alias Model =
    { route : Route
    , session : Maybe Session
    , loginForm: Form
    , newUserForm : Form
    , users : List User
    , current_user : Maybe CurrentUser
    , current_talk : Maybe Talk
    , message : Maybe String
    , map_state : MapState
    , current_location : Maybe Localisation
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

type UserRole
  = ADMIN
  | USER


type alias Session =
    { user : User
    , token : String
    }

type alias Input =
    { input : Maybe String
    , typ : String
    , status : FormStatus
    , validator : Maybe FormValidator
    , id : String
    , label : String
    , tip : Maybe String
    }

type FormStatus
    = Waiting
    | Valid String
    | NotValid String

type FormValidator
    = Required
    | TextValidator Int Int
    | GenderValidator
    | EmailValidator
    | PasswordValidator
    | PasswordConfirmValidator String

type alias AuthResponse =
    { status : String
    , message : Maybe String
    , token : Maybe String
    , user : Maybe User
    }

type alias ApiResponse a =
    { status : String
    , message : Maybe String
    , data : a
    }

type alias User =
    { username : String
    , fname : String
    , lname : String
    , email : String
    , gender : Maybe Gender
    , intIn : Maybe Gender
    , bio : String
    , talks : List String
    , localisation : Maybe Localisation
    , role : UserRole
    }

type alias CurrentUser =
    { username : String
    , gender : Maybe Gender
    , bio : String
    , liked : Bool
    , has_talk : Bool
    }

type Gender
    = M
    | F

type alias Form = List Input

initInput : String -> String -> String -> Maybe FormValidator -> Maybe String -> Input
initInput typ label id validator tip =
    Input Nothing typ Waiting validator id label tip

initLoginForm : Form
initLoginForm =
        [ initInput "text" "Login" "login" (Just <| TextValidator 2 255) Nothing
        , initInput "password" "Mot de passe" "pwd" (Just <| TextValidator 2 255) Nothing
        ]

initNewUserForm : Form
initNewUserForm =
       [ initInput "text" "Login" "login" (Just <| TextValidator 2 255) Nothing
       , initInput "text" "First name" "fname" (Just <| TextValidator 2 255) Nothing
       , initInput "text" "Last name" "lname" (Just <| TextValidator 2 255) Nothing
       , initInput "text" "Email" "email" (Just EmailValidator) Nothing
       , initInput "password" "Password" "pwd" (Just PasswordValidator) (Just "At least 6 chars including 1 number")
       , initInput "password" "Confirm password" "repwd" (Just <| PasswordConfirmValidator "pwd") (Just "Re-enter your password")
       , initInput "text" "Gender" "gender" (Just GenderValidator) Nothing
       , initInput "text" "Interested in" "int_in" (Just GenderValidator) Nothing
       , initInput "text" "Bio" "bio" Nothing Nothing
       ]

initFastNewUserForm : Form
initFastNewUserForm =
       [ initInput "text" "Login" "login" (Just <| TextValidator 2 255) Nothing
       , initInput "text" "Email" "email" (Just EmailValidator) Nothing
       , initInput "password" "Password" "pwd" (Just PasswordValidator) (Just "At least 6 chars and 1 number")
       , initInput "password" "Confirm password" "repwd" (Just <| PasswordConfirmValidator "pwd") (Just "Re-type your password")
       ]

validEmail : Maybe String -> FormStatus
validEmail value =
    case value of
        Nothing -> Waiting
        Just a -> if contains (regex "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$") a then Valid a else NotValid "Must be email"

validPassword : Maybe String -> FormStatus
validPassword value =
    case value of
        Nothing -> Waiting
        Just a -> if contains (regex "\\d") a && String.length a >= 6 then Valid a else NotValid "Should be at least 6 chars and 1 number"

validConfirmPassword : Input -> Maybe String -> FormStatus
validConfirmPassword inp value =
    case inp.status of
        Valid a ->
            case value of
                Just b -> if a == b then Valid a else NotValid "Both password doesn't match"
                Nothing -> Waiting
        _ -> Waiting

validText : Int -> Int -> Maybe String -> FormStatus
validText min max t =
    case t of
        Just s ->
            let
                size = String.length s
            in
            case size >= min && size <= max of
                True -> Valid s
                False -> NotValid <| "Must be more than " ++ toString size ++ " and less than " ++ toString max
        _ -> Waiting

validGender : Maybe String -> FormStatus
validGender g =
    case g of
        Just s ->
            case s of
                "M" -> Valid "M"
                "F" -> Valid "F"
                _ -> NotValid "Must be F or M"
        _ -> Waiting

initialModel : Route -> Model
initialModel route =
    { route = route
    , session = Nothing
    , loginForm =  initLoginForm
    , newUserForm = initFastNewUserForm
    , users = []
    , current_user = Nothing
    , current_talk = Nothing
    , message = Nothing
    , map_state = if route == Account then Loading else NoMap
    , current_location = Nothing
    }
