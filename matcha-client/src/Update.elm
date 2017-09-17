module Update exposing (..)

import Routing exposing (parseLocation)
import RemoteData exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Commands exposing (sendLogin, getUsers, sendNewUser, genderToString, stringToGender)
import Ports exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        UsersResponse response ->
            case Debug.log "UserResponse" response of
                Success users -> 
                    ( { model | users = users }
                    , Cmd.none )
                _ -> 
                    ( model
                    , Navigation.newUrl "/#/login" )

        HandleApiResponse response ->
            case response of
                Success rep ->
                    case rep.status of
                        "success" -> 
                            ( model , Navigation.newUrl "/#/users" )
                        _ -> ( { model | message = rep.message }, Cmd.none)
                _ -> 
                    ( model
                    , Navigation.newUrl "/#/login" )
        
        LoginResponse response -> 
            case Debug.log "response" response of
                Success rep ->
                    case (rep.status == "success", rep.token) of
                        (True, Just t) ->
                            let 
                                token = t
                                user = case List.map (\i -> i.status) model.loginForm of
                                    [ Valid a, b ] -> a
                                    _ -> ""
                                session = Just <| Session user token 
                            in
                            ( { model | session = session, loginForm = initLoginForm }
                            , Cmd.batch [ Navigation.newUrl "/#/users", storeToken [user,token] ]
                            )
                        _ ->
                            ( Debug.log "model on login response" { model | message = rep.message }, Navigation.newUrl "/#/login")
                _ ->
                    ( model 
                    , Navigation.newUrl "/#/login"
                    )

        Logout ->
            ( initialModel (Connect Login), Cmd.batch [Navigation.newUrl "/#/login", deleteSession ()])
        
        SaveToken session ->
            let newSession = 
                case (List.head session, List.tail session) of 
                    (Just user, Just [token]) ->
                        if (token /= "" && user /= "") then Just <| Session user token else Nothing
                    _ -> Nothing
            in
                (Debug.log "model after token" { model | session = newSession }, Navigation.newUrl "/#/users")

        OnLocationChange location -> 
            let
                newRoute =
                    parseLocation location

                cmd = case newRoute of
                    Members ->
                        case model.session of
                            Just s -> getUsers <| Debug.log "sent token" s.token
                            _ -> Navigation.newUrl "/#/login"
                    _ -> Cmd.none
            in
                ( { model | route = newRoute }, cmd )
        

        UpdateLoginForm id value ->
            let
                form = model.loginForm
                newForm = updateInput form id (Just value)
            in
                ( { model | loginForm = newForm }, Cmd.none)

        UpdateNewUserForm id value ->
            let
                form = model.newUserForm
                newForm = updateInput form id (Just value)
            in
                ( { model | newUserForm = newForm }, Cmd.none)


        SendLogin ->
            let
                values = List.map (\i -> i.status) model.loginForm
            in
            case values of
                [ Valid a, Valid b ] -> 
                    (Debug.log "send login" model, sendLogin a b)
                _ ->
                    (model, Cmd.none)
        
        
        NewUser ->
            let
                values = List.map (\i -> i.status) model.newUserForm
            in
            case values of
                [Valid username, Valid fname, Valid lname, Valid email, Valid pwd, Valid repwd, Valid gender, Valid intIn, Valid bio] -> 
                    ( Debug.log "new user ok" model, sendNewUser username fname lname email pwd repwd gender intIn bio)
                _ ->
                    (Debug.log "new user nok" model, Cmd.none)


updateInput : Form -> String -> Maybe String -> Form
updateInput form id value =
    List.map (\i -> 
        if i.id == id then 
            { i 
            | input = value
            , status = validationForm i.validator form value 
            } 
        else i) form

validationForm : Maybe FormValidator -> Form -> Maybe String -> FormStatus
validationForm validator form value =
    case validator of 
        Nothing -> Waiting
        Just Required -> case value of 
                    Just a -> if a /= "" then Valid a else NotValid "Required Field"
                    Nothing -> NotValid "Required field"
        Just GenderValidator -> validGender value
        Just EmailValidator -> validEmail value
        Just PasswordValidator -> validPassword value
        Just (PasswordConfirmValidator id) -> 
            case findInput form id of 
                Just a -> validConfirmPassword a value
                Nothing -> NotValid ("No input found with id : " ++ id)
        Just (TextValidator min max) -> validText min max value

findInput : Form -> String -> Maybe Input
findInput form id =
    case List.filter (\i -> i.id == id) form of
        a :: b -> Just a
        _ -> Nothing

