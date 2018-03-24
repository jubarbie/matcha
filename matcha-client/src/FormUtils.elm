module FormUtils exposing (..)

import App.User.UserModel exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex exposing (..)


type alias Form =
    List Input


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
    | TagValidator


initInput : Maybe String -> String -> String -> String -> Maybe FormValidator -> Maybe String -> Input
initInput value typ label id validator tip =
    Input value typ (validationForm validator [] value) validator id label tip


updateInput : Form -> String -> Maybe String -> Form
updateInput form id value =
    List.map
        (\i ->
            if i.id == id then
                { i
                    | input = value
                    , status = validationForm i.validator form value
                }
            else
                i
        )
        form


validationForm : Maybe FormValidator -> Form -> Maybe String -> FormStatus
validationForm validator form value =
    case validator of
        Nothing ->
            Valid
                (case value of
                    Just a ->
                        a

                    _ ->
                        ""
                )

        Just Required ->
            case value of
                Just a ->
                    if a /= "" then
                        Valid a
                    else
                        NotValid "Required Field"

                Nothing ->
                    NotValid "Required field"

        Just GenderValidator ->
            validGender value

        Just EmailValidator ->
            validEmail value

        Just PasswordValidator ->
            validPassword value

        Just (PasswordConfirmValidator id) ->
            case findInput form id of
                Just a ->
                    validConfirmPassword a value

                Nothing ->
                    NotValid ("No input found with id : " ++ id)

        Just (TextValidator min max) ->
            validText min max value

        Just TagValidator ->
            validTag value


findInput : Form -> String -> Maybe Input
findInput form id =
    case List.filter (\i -> i.id == id) form of
        a :: b ->
            Just a

        _ ->
            Nothing


initEditAccountForm : SessionUser -> Form
initEditAccountForm user =
    [ initInput (Just user.fname) "text" "First name" "fname" (Just <| TextValidator 2 255) Nothing
    , initInput (Just user.lname) "text" "Last name" "lname" (Just <| TextValidator 2 255) Nothing
    , initInput (Just user.email) "text" "Email" "email" (Just EmailValidator) Nothing
    , initInput (Just user.bio) "textarea" "Bio" "bio" Nothing Nothing
    ]


initLoginForm : Form
initLoginForm =
    [ initInput Nothing "text" "Login" "login" (Just <| TextValidator 2 255) Nothing
    , initInput Nothing "password" "Mot de passe" "pwd" (Just <| TextValidator 2 255) Nothing
    ]


initResetPwdForm : Form
initResetPwdForm =
    [ initInput Nothing "text" "Login" "login" Nothing Nothing
    , initInput Nothing "text" "Email" "email" (Just EmailValidator) Nothing
    ]


initChangePwdForm : Form
initChangePwdForm =
    [ initInput Nothing "password" "Ancien mot de passe" "old_pwd" Nothing Nothing
    , initInput Nothing "password" "Nouveau mot de passe" "new_pwd" (Just PasswordValidator) (Just "At least 6 chars including 1 number")
    , initInput Nothing "password" "Confirmer le mot de passe" "confirm_new_pwd" (Just <| PasswordConfirmValidator "new_pwd") (Just "Re-enter your password")
    ]


initNewUserForm : Form
initNewUserForm =
    [ initInput Nothing "text" "Login" "login" (Just <| TextValidator 2 255) Nothing
    , initInput Nothing "text" "First name" "fname" (Just <| TextValidator 2 255) Nothing
    , initInput Nothing "text" "Last name" "lname" (Just <| TextValidator 2 255) Nothing
    , initInput Nothing "text" "Email" "email" (Just EmailValidator) Nothing
    , initInput Nothing "password" "Password" "pwd" (Just PasswordValidator) (Just "At least 6 chars including 1 number")
    , initInput Nothing "password" "Confirm password" "repwd" (Just <| PasswordConfirmValidator "pwd") (Just "Re-enter your password")
    , initInput Nothing "text" "Gender" "gender" (Just GenderValidator) Nothing
    , initInput Nothing "text" "Interested in" "int_in" (Just GenderValidator) Nothing
    , initInput Nothing "text" "Bio" "bio" Nothing Nothing
    ]


initFastNewUserForm : Form
initFastNewUserForm =
    [ initInput Nothing "text" "Login" "login" (Just <| TextValidator 2 255) Nothing
    , initInput Nothing "text" "First name" "fname" (Just <| TextValidator 2 255) Nothing
    , initInput Nothing "text" "Last name" "lname" (Just <| TextValidator 2 255) Nothing
    , initInput Nothing "text" "Email" "email" (Just EmailValidator) Nothing
    , initInput Nothing "password" "Password" "pwd" (Just PasswordValidator) (Just "At least 6 chars and 1 number")
    , initInput Nothing "password" "Confirm password" "repwd" (Just <| PasswordConfirmValidator "pwd") (Just "Re-type your password")
    ]


validEmail : Maybe String -> FormStatus
validEmail value =
    case value of
        Nothing ->
            Waiting

        Just a ->
            if contains (regex "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$") a then
                Valid a
            else
                NotValid "Must be email"


validTag : Maybe String -> FormStatus
validTag value =
    case value of
        Nothing ->
            Waiting

        Just a ->
            if contains (regex "^[a-zA-Z0-9_.+-]+$") a then
                Valid a
            else
                NotValid "Only numbers and chars"


validPassword : Maybe String -> FormStatus
validPassword value =
    case value of
        Nothing ->
            Waiting

        Just a ->
            if contains (regex "\\d") a && String.length a >= 6 then
                Valid a
            else
                NotValid "Should be at least 6 chars and 1 number"


validConfirmPassword : Input -> Maybe String -> FormStatus
validConfirmPassword inp value =
    case inp.status of
        Valid a ->
            case value of
                Just b ->
                    if a == b then
                        Valid a
                    else
                        NotValid "Both password doesn't match"

                Nothing ->
                    Waiting

        _ ->
            Waiting


validText : Int -> Int -> Maybe String -> FormStatus
validText min max t =
    case t of
        Just s ->
            let
                size =
                    String.length s
            in
            case size >= min && size <= max of
                True ->
                    Valid s

                False ->
                    NotValid <| "Must be more than " ++ toString size ++ " and less than " ++ toString max

        _ ->
            Waiting


validGender : Maybe String -> FormStatus
validGender g =
    case g of
        Just s ->
            case s of
                "M" ->
                    Valid "M"

                "F" ->
                    Valid "F"

                _ ->
                    NotValid "Must be F or M"

        _ ->
            Waiting


viewInput : (String -> a) -> Input -> Html a
viewInput mess i =
    let
        inputClass =
            case i.status of
                NotValid err ->
                    "input input-error"

                Valid a ->
                    "input input-success"

                Waiting ->
                    "input"
    in
    div [ class inputClass ]
        [ label [ for i.id ] [ text i.label ]
        , if i.typ == "textarea" then
            viewTextareaField mess i
          else
            viewInputField mess i
        , case i.tip of
            Just tip ->
                div [ class "input-tip" ] [ text tip ]

            _ ->
                div [] []
        ]


viewInputField : (String -> a) -> Input -> Html a
viewInputField mess i =
    input
        [ type_ i.typ
        , id i.id
        , onInput mess
        , value <|
            case i.input of
                Just val ->
                    val

                _ ->
                    ""
        ]
        []


viewTextareaField : (String -> a) -> Input -> Html a
viewTextareaField mess i =
    textarea
        [ id i.id
        , onInput mess
        , value <|
            case i.input of
                Just val ->
                    val

                _ ->
                    ""
        ]
        []
