module Update exposing (..)

import Routing exposing (parseLocation)
import RemoteData exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Commands exposing (..)
import Ports exposing (..)
import Task
import FormUtils exposing (..)
import UserModel exposing (..)

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
                    ( { model | users = users, current_user = Nothing }
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
                            newModel = { model | session = Just <| Session u token, editAccountForm = initEditAccountForm u }
                            cmd = case model.route of
                                  ChatRoute a ->
                                    case newModel.session of
                                        Just s -> getTalk a s.token
                                        _ -> Navigation.newUrl "/#/login"
                                  Members ->
                                    case newModel.session of
                                        Just s -> getUsers s.token
                                        _ -> Navigation.newUrl "/#/login"
                                  UsersRoute ->
                                      case newModel.session of
                                          Just s -> getRelevantUsers s.token
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
                                ( { model | current_user = Nothing }, Cmd.none )
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

        EditAccountResponse email fname lname gender intIn bio response ->
            case Debug.log "resp" response of
                Success rep ->
                    case (rep.status, model.session ) of
                        ("success", Just s) ->
                          let
                            user = s.user
                            newUser = { user | email = email, fname = fname, lname = lname, gender = stringToGender gender, intIn = stringToGender intIn, bio = bio }
                          in
                            ( { model | message = Just "Information saved", session = Just { s | user = newUser } }, Cmd.none )
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
                      (True, mess) ->
                          let ctalk =
                            case (mess, model.route) of
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

        SaveLocRespone response ->
          case Debug.log "response new message" response of
              Success rep ->
                  case rep.status of
                    "success" ->
                      let
                        session =
                          case (model.session, model.current_location) of
                            (Just s, Just l) ->
                              let user = s.user in Just { s | user = { user | localisation = Just l } }
                            _ -> Nothing
                      in
                          ( { model | session = session }, Cmd.none )
                    _ -> ( { model | message = Just "Error while saving localisation. Try again" }, Cmd.none )
              _ -> ( { model | message = Just "Error while saving localisation. Try again" }, Cmd.none )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location

                ret = case newRoute of
                    ChatsRoute ->
                      case model.session of
                          Just s -> ( { model | route = newRoute }, getTalks s.token)
                          _ -> ( model, Navigation.newUrl "/#/login")
                    ChatRoute a ->
                      case model.session of
                          Just s -> ( { model | route = newRoute }, getTalk a s.token)
                          _ -> (model, Navigation.newUrl "/#/login")
                    Members ->
                      case model.session of
                          Just s -> ( { model | route = newRoute }, getUsers s.token)
                          _ -> (model, Navigation.newUrl "/#/login")
                    UsersRoute ->
                        case model.session of
                            Just s -> ( { model | route = newRoute }, getRelevantUsers s.token)
                            _ -> ( model, Navigation.newUrl "/#/login")
                    UserRoute a ->
                        case model.session of
                            Just s -> ( { model | route = newRoute }, getCurrentUser a s.token)
                            _ -> (model, Navigation.newUrl "/#/login")
                    AccountRoute ->
                        case model.session of
                            Just s -> ( { model | route = newRoute, map_state = Models.Loading }, Cmd.none)
                            _ -> ( model, Navigation.newUrl "/#/login")
                    EditAccountRoute ->
                        case model.session of
                            Just s ->
                              ( { model | route = newRoute, editAccountForm = initEditAccountForm s.user }, Cmd.none)
                            _ -> ( model, Navigation.newUrl "/#/login")
                    _ -> ( { model | route = newRoute }, Cmd.none)
            in
                ret

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

        SaveLocation ->
          case ( model.session, model.current_location ) of
            (Just s, Just l) -> ( model, saveLocation s.token l )
            _ -> ( model, Cmd.none )

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

        FetchTalk a t ->
          case model.session of
              Just s -> ( model, Cmd.none )
              _ -> (model, Navigation.newUrl "/#/login")

        LoadMap t ->
          case (model.map_state, model.route) of
              (Models.Loading, AccountRoute) ->
                let
                  cmd = case model.session of
                    Just s -> case s.user.localisation of
                      Just l -> localize [l.lon, l.lat]
                      _ -> getIpLocalisation
                    _ -> Cmd.none
                in
                  ( { model | map_state = Models.Rendered }, cmd )
              _ -> (model, Cmd.none)

        Localize ->
          ( model, getIpLocalisation)

        SetNewLocalisation loc ->
         case Debug.log "new loc" loc of
            [long, lat] -> ( { model | current_location = Just <| Localisation long lat }, Cmd.none )
            _ -> ( model, Cmd.none )

        GetIpLocalisation resp ->
          case Debug.log "local" resp of
            Success locapi ->
              let
                loc =
                  case (locapi.status, locapi.lon, locapi.lat) of
                    ("success", Just lo, Just la) -> Just <| Localisation lo la
                    _ -> Nothing
              in
                ( { model | current_location = loc }
                , localize <|
                    ( case loc of
                      Just l -> [l.lon, l.lat]
                      _ -> [] )
                )
            _ -> (model, Cmd.none)

        UpdateEditAccountForm id value ->
          let
              form = model.editAccountForm
              newForm = updateInput form id (Just value)
          in
              ( { model | editAccountForm = newForm }, Cmd.none)

        SaveAccountUpdates ->
          case model.session of
              Just s ->
                let
                    values = List.map (\i -> i.status) model.editAccountForm
                in
                case Debug.log "values" values of
                    [Valid fname, Valid lname, Valid email, Valid gender, Valid int_in, Valid bio] ->
                        (model, updateAccountInfos s.token fname lname email gender int_in bio)
                    _ ->
                        (model, Cmd.none)
              _ -> (model, Navigation.newUrl "/#/login")
