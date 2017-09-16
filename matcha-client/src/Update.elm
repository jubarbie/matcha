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
                            let token = t
                                user = case model.loginForm.login.validation of
                                    Valid a -> a
                                    _ -> ""
                                session = Just <| Session user token 
                            in
                            ( { model | session = session, loginForm = initLoginForm}
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
        
        UpdateLoginInput value ->
            let
                lf = model.loginForm
                input = lf.login
                newInput = { input | validation = Valid value }
                newLoginForm = { lf | login = input }
            in
                ( { model | loginForm = newLoginForm }, Cmd.none)
        
        UpdatePasswordInput value ->
            let
                lf = model.loginForm
                input = lf.password
                newInput = { input | validation = Valid value }
                newLoginForm = { lf | password = input }
            in
                ( { model | loginForm = newLoginForm }, Cmd.none)
        
        UpdateUsernameInput value ->
            let
                form = model.newUserForm
                input = form.username
                newInput = { input | validation = Valid value }
                newForm = { form | username = input }
            in
                ( { model | newUserForm = newForm }, Cmd.none)
        
        UpdateFnameInput value ->
            let
                form = model.newUserForm
                input = form.fname
                newInput = { input | validation = Valid value }
                newForm = { form | fname = input }
            in
                ( { model | newUserForm = newForm }, Cmd.none)
        
        UpdateLnameInput value ->
            let
                form = model.newUserForm
                input = form.lname
                newInput = { input | validation = Valid value }
                newForm = { form | lname = input }
            in
                ( { model | newUserForm = newForm }, Cmd.none)
        
        UpdateEmailInput value ->
            let
                form = model.newUserForm
                input = form.email
                newInput = { input | validation = Valid value }
                newForm = { form | email = input }
            in
                ( { model | newUserForm = newForm }, Cmd.none)
        
        UpdatePwdInput value ->
            let
                form = model.newUserForm
                input = form.password
                newInput = { input | validation = Valid value }
                newForm = { form | password = input }
            in
                ( { model | newUserForm = newForm }, Cmd.none)
        
        UpdateRePwdInput value ->
            let
                form = model.newUserForm
                input = form.rePassword
                newInput = { input | validation = Valid value }
                newForm = { form | rePassword = input }
            in
                ( { model | newUserForm = newForm }, Cmd.none)

        UpdateGenderInput value ->
            let
                form = model.newUserForm
                input = form.gender
                newInput = { input | validation = stringToGender value }
                newForm = { form | gender = input }
            in
                ( { model | newUserForm = newForm }, Cmd.none)

        UpdateIntInInput value ->
            let
                form = model.newUserForm
                input = form.intIn
                newInput = { input | validation = stringToGender value }
                newForm = { form | intIn = input }
            in
                ( { model | newUserForm = newForm }, Cmd.none)

        UpdateBioInput value ->
            let
                form = model.newUserForm
                input = form.bio
                newInput = { input | validation = Valid value }
                newForm = { form | bio = input }
            in
                ( { model | newUserForm = newForm }, Cmd.none)


        SendLogin ->
            case (model.loginForm.login.validation, model.loginForm.password.validation) of
                (Valid a, Valid b) -> 
                    (Debug.log "send login" model, sendLogin a b)
                _ ->
                    (model, Cmd.none)
        
        
        NewUser ->
            case 
                ( model.newUserForm.username.validation
                , model.newUserForm.fname.validation
                , model.newUserForm.lname.validation
                , model.newUserForm.password.validation
                , model.newUserForm.rePassword.validation
                , model.newUserForm.email.validation
                , model.newUserForm.gender.validation
                , model.newUserForm.intIn.validation
                , model.newUserForm.bio.validation
                ) of
                (Valid username, Valid fname, Valid lname, Valid pwd, Valid repwd, Valid email, Valid gender, Valid intIn, Valid bio) -> 
                    ( Debug.log "new user ok" model, sendNewUser username fname lname email pwd repwd (genderToString gender) (genderToString intIn) bio)
                _ ->
                    (Debug.log "new user nok" model, Cmd.none)

