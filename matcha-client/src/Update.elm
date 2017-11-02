module Update exposing (..)

import Routing exposing (parseLocation)
import RemoteData exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Commands exposing (..)
import Ports exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Logout ->
            ( initialModel (Connect Login), Cmd.batch [Navigation.newUrl "/#/login", deleteSession ()])

        SaveToken session ->
            let cmd =
                case Debug.log "session" session of
                    [user, token] ->
                        if (Debug.log "token" token /= "" && Debug.log "user" user /= "") then
                            getProfile user token
                        else
                             Cmd.none
                    _ -> Cmd.none
            in
                (model, cmd)

        UsersResponse response ->
            case response of
                Success users ->
                    ( { model | users = users }
                    , Cmd.none )
                _ ->
                    ( model
                    , Navigation.newUrl "/#/login" )

        ProfileResponse token response ->
            case Debug.log "response user" response of
                Success rep ->
                    case (rep.status == "success", rep.data) of
                        (True, Just u) ->
                          let
                            newModel = { model | session = Just <| Session u token }
                            cmd = case model.route of
                                  ChatRoute a ->
                                    case newModel.session of
                                        Just s -> getTalk a s.token
                                        _ -> Navigation.newUrl "/#/login"
                                  Members ->
                                    case newModel.session of
                                        Just s -> getUsers s.user.username s.token
                                        _ -> Navigation.newUrl "/#/login"
                                  UsersRoute ->
                                      case newModel.session of
                                          Just s -> getUsers s.user.username s.token
                                          _ -> Navigation.newUrl "/#/login"
                                  UserRoute a ->
                                      case newModel.session of
                                          Just s -> getCurrentUser a s.token
                                          _ -> Navigation.newUrl "/#/login"
                                  _ -> Cmd.none
                              in
                                ( newModel, cmd )
                        _ -> (model, Navigation.newUrl "/#/login")
                _ ->
                    ( model
                    , Navigation.newUrl "/#/login" )

        UserResponse response ->
            case Debug.log "response user" response of
                Success rep ->
                    case (rep.status == "success", rep.data) of
                        (True, Just u) ->
                                ( model, Cmd.none )
                        _ -> ( {model | message = Just "user not found" }, Navigation.newUrl  "/#/users")
                _ ->
                    ( model
                    , Navigation.newUrl "/#/login" )

        CurrentUserResponse response ->
          case Debug.log "response currentUser" response of
              Success rep ->
                  case (rep.status == "success", rep.data) of
                      (True, Just u) ->
                              ( { model | current_user = Just u }, Cmd.none )
                      _ -> ( { model | message = Just "user not found" }, Navigation.newUrl  "/#/users")
              _ ->
                  ( model
                  , Navigation.newUrl "/#/login" )

        NewUserResponse response ->
            case Debug.log "resp" response of
                Success rep ->
                    case rep.status of
                        "success" ->
                            ( model , Navigation.newUrl "/#/users" )
                        _ -> ( { model | message = rep.message, newUserForm = initFastNewUserForm }, Cmd.none)
                _ ->
                    ( model
                    , Navigation.newUrl "/#/login" )

        DeleteUserResponse username response ->
            case Debug.log "resp" response of
                Success rep ->
                    case rep.status of
                        "success" ->
                            let
                              newUsers = List.filter (\u -> u.username /= username ) model.users
                            in
                            ( { model  | users = newUsers }, Cmd.none )
                        _ -> ( { model | message = rep.message }, Navigation.newUrl "/#/login")
                _ ->
                    ( model, Navigation.newUrl "/#/login" )

        ToggleLikeResponse username response ->
            case Debug.log "resp" response of
                Success rep ->
                    case rep.status of
                        "success" ->
                            let
                              newCurrentUser =
                                case model.current_user of
                                  Just u -> Just { u | liked = (rep.message == Just "liked") }
                                  _ -> Nothing
                            in
                            ( { model  | current_user = newCurrentUser }, Cmd.none )
                        _ -> ( model, Navigation.newUrl "/#/login")
                _ ->
                    ( model, Navigation.newUrl "/#/login" )

        LoginResponse response ->
            case Debug.log "Login response" response of
                Success rep ->
                    case (rep.status == "success", rep.token, rep.user) of
                        (True, Just t, Just user) ->
                            let
                                session = Just <| Session user t
                            in
                            ( { model | session = session, loginForm = initLoginForm }
                            , Cmd.batch [ Navigation.newUrl "/#/users", storeToken [ user.username,t ] ]
                            )
                        _ ->
                            ( { model | message = rep.message }, Navigation.newUrl "/#/login")
                _ ->
                    ( model
                    , Navigation.newUrl "/#/login"
                    )

        GetTalkResponse response ->
          case Debug.log "response talk" response of
              Success rep ->
                  case (rep.status == "success", rep.data) of
                      (True, talk) ->
                          let ctalk =
                            case (talk, model.route) of
                              (Just t, ChatRoute u ) -> Just <| Talk t u ""
                              _ -> Nothing
                            in
                              ( { model | current_talk = ctalk } , Cmd.none )
                      _ -> ( { model | message = Just "user not found" }, Navigation.newUrl  "/#/users")
              _ ->
                  ( model
                  , Navigation.newUrl "/#/login" )

        GetTalksResponse response ->
          case Debug.log "response talk" response of
              Success rep ->
                  case (rep.status == "success", rep.data) of
                      (True, Just talks) ->
                              let
                                newSess = case model.session of
                                  Just s ->
                                    let
                                      user = s.user
                                      newUser = { user | talks = talks }
                                    in
                                      Just { s | user = newUser }
                                  _ -> Nothing
                              in
                                ( { model | session = newSess } , Cmd.none )
                      _ -> ( {model | message = Just "user not found" }, Navigation.newUrl  "/#/users")
              _ ->
                  ( model
                  , Navigation.newUrl "/#/login" )

        NewMessageResponse response ->
          case Debug.log "response new message" response of
              Success rep ->
                  case rep.status == "success" of
                      True ->
                        let
                          newTalk =
                            case model.current_talk of
                              Just t -> Just { t | messages = ( (Message "date" t.new_message "user") :: t.messages ), new_message = "" }
                              _ -> Nothing
                        in
                          ( { model | current_talk = newTalk }, Cmd.none )
                      _ -> ( model , Cmd.none )
              _ ->
                  ( { model | message = Just "Error while sending new message. Try again baby" }, Cmd.none )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location

                cmd = case newRoute of
                    ChatsRoute ->
                      case model.session of
                          Just s -> getTalks s.token
                          _ -> Navigation.newUrl "/#/login"
                    ChatRoute a ->
                      case model.session of
                          Just s -> getTalk a s.token
                          _ -> Navigation.newUrl "/#/login"
                    Members ->
                      case model.session of
                          Just s -> getUsers s.user.username s.token
                          _ -> Navigation.newUrl "/#/login"
                    UsersRoute ->
                        case model.session of
                            Just s -> getUsers s.user.username s.token
                            _ -> Navigation.newUrl "/#/login"
                    UserRoute a ->
                        case model.session of
                            Just s -> getCurrentUser a s.token
                            _ -> Navigation.newUrl "/#/login"
                    _ -> Cmd.none
            in
                ( { model | route = newRoute }, cmd )

        GoBack amount ->
          (model, Navigation.back amount)

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
                    (model, sendLogin a b)
                _ ->
                    (model, Cmd.none)


        NewUser ->
            let
                values = List.map (\i -> i.status) model.newUserForm
            in
            case values of
                [Valid username, Valid email, Valid pwd, Valid repwd] ->
                    (model, sendFastNewUser username email pwd repwd)
                _ ->
                    (model, Cmd.none)

        DeleteUser username ->
          case model.session of
            Just s -> (model, deleteUser username s.token)
            _ -> (model, Navigation.newUrl "/#/login")

        ToggleLike username ->
            case model.session of
              Just s -> (model, toggleLike username s.token)
              _ -> (model, Navigation.newUrl "/#/login")

        Localize ->
            (model, localize ())

        UpdateNewMessage msg ->
          let
            newTalk =
              case model.current_talk of
                Just t -> Just { t | new_message = msg }
                _ -> Nothing
          in
            ( { model | current_talk = newTalk } , Cmd.none)

        SendNewMessage ->
          case ( model.session, model.current_talk ) of
            ( Just s, Just t ) ->
              ( model, sendMessage s.token t.username_with t.new_message )
            _ ->
              ( model, Cmd.none )

        NewMessage str ->
          ( { model | message = Just str }, Cmd.none )

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
        Nothing -> Valid (case value of
            Just a -> a
            _ -> "")
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
