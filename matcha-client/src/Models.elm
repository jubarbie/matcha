module Models exposing (..)

import Regex exposing (..)


type Route
    = Connect LoginRoute
    | Users (Maybe User)
    | Chat
    | Account
    | NotFoundRoute

type LoginRoute
    = Login
    | Signin

type alias Model =
    { route : Route
    , session : Maybe Session
    , loginForm: Form
    , newUserForm : Form
    , users : List User
    , message : Maybe String
    }

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
    , gender : Gender
    , intIn : Gender
    , bio : String
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
       , initInput "text" "Prénom" "fname" (Just <| TextValidator 2 255) Nothing
       , initInput "text" "Nom" "lname" (Just <| TextValidator 2 255) Nothing
       , initInput "text" "Email" "email" (Just EmailValidator) Nothing
       , initInput "password" "Mot de passe" "pwd" (Just PasswordValidator) (Just "Minimum 6 caractère dont au moins un chiffre")
       , initInput "password" "Confirmation mot de passe" "repwd" (Just <| PasswordConfirmValidator "pwd") (Just "Retaper le même mot de passe")
       , initInput "text" "Genre" "gender" (Just GenderValidator) Nothing
       , initInput "text" "Intéressé par" "int_in" (Just GenderValidator) Nothing
       , initInput "text" "Bio" "bio" Nothing Nothing
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
        Just a -> if contains (regex "\\d") a && String.length a >= 6 then Valid a else NotValid "Should be at least 6 char and 1 number"

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
    , newUserForm = initNewUserForm
    , users = []
    , message = Nothing
    }
