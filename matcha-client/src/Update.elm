module Update exposing (..)

import Talk.TalkUtils exposing (..)
import Commands exposing (..)
import User.UserCommands exposing (..)
import Talk.TalkCommands exposing (..)
import Dom.Scroll as Scroll
import FormUtils exposing (..)
import Json.Decode
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Ports exposing (..)
import RemoteData exposing (..)
import Routing exposing (parseLocation)
import Task
import Time
import User.UserModel exposing (..)
import User.UserHelper exposing (..)
import Talk.TalkModel exposing (..)
import Notif.NotifModel exposing (..)
import Notif.NotifDecoder exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg oldModel =
    let
        model =
            { oldModel | message = Nothing }

        doIfConnected cmd =
            case model.session of
                Just s ->
                    cmd s.token

                _ ->
                    Navigation.newUrl "/#/login"
    in
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Logout ->
            ( initialModel (Connect Login), Cmd.batch [ Navigation.newUrl "/#/login", deleteSession () ] )

        SaveToken session ->
            case session of
                [ user, token ] ->
                    if token /= "" && user /= "" then
                        ( model, getSessionUser user token )
                    else
                        ( model, Navigation.newUrl "/#/login" )

                _ ->
                    ( model, Navigation.newUrl "/#/login" )

        ChangePwdRespone response ->
            case response of
                Success rep ->
                    case ( rep.status, rep.message ) of
                        ( "success", _ ) ->
                            ( { model | message = Just "The password was succefully updated" }, Navigation.newUrl "/#/account" )

                        ( "error", Just msg ) ->
                            ( { model | message = Just msg }, Cmd.none )

                        _ ->
                            ( { model | message = Just "Network error. Please try again" }, Cmd.none )

                _ ->
                    ( { model | message = Just "Network error. Please try again" }, Cmd.none )

        ReqTagResponse response ->
            case response of
                Success rep ->
                    case ( rep.status, rep.data, model.session ) of
                        ( "success", Just d, Just s ) ->
                            let
                                u =
                                    s.user

                                newUser =
                                    { u | tags = d }

                                newSession =
                                    { s | user = newUser }
                            in
                            ( { model | session = Just newSession }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SearchTagResponse response ->
            case response of
                Success rep ->
                    case ( rep.status, rep.data ) of
                        ( "success", Just d ) ->
                            ( { model | searchTag = d }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UpdateFieldResponse token response ->
            case response of
                Success rep ->
                    case ( rep.status, rep.data, rep.message ) of
                        ( "success", Just u, _ ) ->
                            ( { model | session = Just <| Session u token, mImage = Nothing }, Cmd.none )

                        ( "error", _, Just msg ) ->
                            ( { model | message = Just msg }, Cmd.none )

                        _ ->
                            ( { model | message = Just "Network error. Please try again", mImage = Nothing }, Cmd.none )

                _ ->
                    ( { model | message = Just "Network error. Please try again", mImage = Nothing }, Cmd.none )

        UsersResponse response ->
            case response of
                Success rep ->
                    case ( rep.status == "success", rep.data ) of
                        ( True, Just u ) ->
                            ( { model | users = u, current_user = Nothing }, Cmd.none )

                        _ ->
                            ( { model | message = Just "Network errror. Please try again" }, Cmd.none )

                _ ->
                    ( { model | message = Just "Network error. Please try again" }, Cmd.none )

        UsersAdminResponse response ->
            case response of
                Success rep ->
                    case ( rep.status == "success", Debug.log "repsp" rep.data ) of
                        ( True, Just u ) ->
                            ( { model | usersAdmin = u, current_user = Nothing }, Cmd.none )

                        _ ->
                            ( { model | message = Just "Network errror. Please try again" }, Cmd.none )

                _ ->
                    ( { model | message = Just "Network error. Please try again" }, Cmd.none )

        SessionUserResponse token response ->
            case Debug.log "response user" response of
                Success rep ->
                    case ( rep.status == "success", rep.data ) of
                        ( True, Just u ) ->
                            let
                                newSession =
                                    Session u token

                                newModel =
                                    { model | session = Just newSession, editAccountForm = initEditAccountForm u }
                            in
                            case u.status of
                                Activated ->
                                    case newModel.route of
                                        TalksRoute ->
                                            ( newModel, getTalks newSession.token )

                                        TalkRoute a ->
                                            ( newModel, getTalk a True newSession.token )

                                        UsersRoute a ->
                                            ( newModel, Cmd.batch [ sendLikeNotif newSession.token u.username, sendVisitNotif newSession.token u.username, getRelevantUsers a newSession.token] )

                                        UserRoute a ->
                                            ( { newModel | current_user = findUserByName a model.users }, Cmd.batch [ sendLikeNotif newSession.token u.username, sendVisitNotif newSession.token u.username, getRelevantUsers a newSession.token] )

                                        AccountRoute ->
                                            ( { newModel | map_state = Models.Loading }, Cmd.none )

                                        EditAccountRoute ->
                                            ( { newModel | editAccountForm = initEditAccountForm newSession.user }, Cmd.none )

                                        _ ->
                                            ( newModel, sendLikeNotif newSession.token u.username )

                                ResetPassword ->
                                    ( { newModel | message = Just "Please reset your password" }, Navigation.newUrl "/#/account" )

                                Incomplete ->
                                    ( { newModel | message = Just "Please complete your profile" }, Navigation.newUrl "/#/account" )

                                _ ->
                                    ( newModel, Navigation.newUrl "/#/login" )

                        _ ->
                            ( model, Navigation.newUrl "/#/login" )

                _ ->
                    ( model, Navigation.newUrl "/#/login" )

        UserResponse response ->
            case response of
                Success rep ->
                    case ( rep.status == "success", rep.data, model.session ) of
                        ( True, Just u, Just s ) ->
                            ( { model | users = updateUser u model.users }, sendVisitNotif s.token u.username )

                        _ ->
                            ( { model | message = Just "User not found" }, Cmd.none )

                _ ->
                    ( model
                    , Navigation.newUrl "/#/login"
                    )

        ResetPwdResponse response ->
            case response of
                Success rep ->
                    if rep.status == "success" then
                        ( { model | message = Just "A email have been sent with your new password" }, Navigation.newUrl "/#/login" )
                    else
                        ( { model | message = Just "Unknown user" }, Cmd.none )

                _ ->
                    ( model
                    , Navigation.newUrl "/#/login"
                    )

        NewUserResponse response ->
            case Debug.log "resp" response of
                Success rep ->
                    case rep.status of
                        "success" ->
                            ( { model | message = Just "Your account has been created, check your emails" }, Navigation.newUrl "/#/login" )

                        _ ->
                            ( { model | message = rep.message, newUserForm = initFastNewUserForm }, Cmd.none )

                _ ->
                    ( model
                    , Navigation.newUrl "/#/login"
                    )

        EditAccountResponse email fname lname bio response ->
            case Debug.log "resp" response of
                Success rep ->
                    case ( rep.status, model.session ) of
                        ( "success", Just s ) ->
                            let
                                user =
                                    s.user

                                newUser =
                                    { user | email = email, fname = fname, lname = lname, bio = bio }
                            in
                            ( { model | message = Just "Information saved", session = Just { s | user = newUser } }, Navigation.newUrl "/#/account" )

                        _ ->
                            ( { model | message = rep.message, newUserForm = initFastNewUserForm }, Cmd.none )

                _ ->
                    ( model
                    , Navigation.newUrl "/#/login"
                    )

        ToggleLikeResponse username response ->
            case Debug.log "resp" response of
                Success rep ->
                    case ( rep.status, rep.data, model.session ) of
                        ( "success", Just m, Just s ) ->
                            let
                                anim =
                                    case m of
                                        Match ->
                                            Just 1.0

                                        _ ->
                                            Nothing

                                newCurrentUser =
                                    case model.current_user of
                                        Just u ->
                                            Just { u | match = m }

                                        _ ->
                                            Nothing
                            in
                            ( { model | current_user = newCurrentUser, matchAnim = anim }, sendLikeNotif s.token username )

                        _ ->
                            ( model, Navigation.newUrl "/#/login" )

                _ ->
                    ( model, Navigation.newUrl "/#/login" )

        LoginResponse response ->
            case Debug.log "Login response" response of
                Success rep ->
                    case ( rep.status == "success", rep.token, rep.user ) of
                        ( True, Just t, Just user ) ->
                            let
                                session =
                                    Just <| Session user t

                                ( route, msg ) =
                                    case user.status of
                                        ResetPassword ->
                                            ( "/#/account", Just "Please reset your password" )

                                        _ ->
                                            ( "/#/users", Nothing )
                            in
                            ( { model | session = session, message = msg }
                            , Cmd.batch [ Navigation.newUrl route, storeToken [ user.username, t ] ]
                            )

                        _ ->
                            ( { model | message = rep.message }, Navigation.newUrl "/#/login" )

                _ ->
                    ( model
                    , Navigation.newUrl "/#/login"
                    )

        GetTalkResponse response ->
            case Debug.log "response talk" response of
                Success rep ->
                    case ( rep.status, rep.data ) of
                        ( "success", talk ) ->
                            ( { model | talks = updateTalks talk model.talks }, Task.attempt (always NoOp) <| Scroll.toBottom "talk-list" )

                        _ ->
                            ( { model | message = Just "user not found" }, Navigation.newUrl "/#/users" )

                _ ->
                    ( model
                    , Navigation.newUrl "/#/login"
                    )

        GetTalksResponse response ->
            case Debug.log "response talk" response of
                Success rep ->
                    case ( rep.status == "success", rep.data ) of
                        ( True, Just talks ) ->
                            ( { model | talks = talks }, Cmd.none )

                        _ ->
                            ( { model | message = Just "user not found" }, Navigation.newUrl "/#/users" )

                _ ->
                    ( model
                    , Navigation.newUrl "/#/login"
                    )

        NewMessageResponse response ->
            case Debug.log "response new message" response of
                Success rep ->
                    case rep.status == "success" of
                        True ->
                            let
                                newTalk =
                                    case model.current_talk of
                                        Just t ->
                                            Just { t | messages = Message "date" t.new_message "user" :: t.messages, new_message = "" }

                                        _ ->
                                            Nothing
                            in
                            ( { model | current_talk = newTalk }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( { model | message = Just "Error while sending new message. Try again baby" }, Cmd.none )

        SaveLocRespone response ->
            case Debug.log "response new message" response of
                Success rep ->
                    case rep.status of
                        "success" ->
                            let
                                session =
                                    case ( model.session, model.current_location ) of
                                        ( Just s, Just l ) ->
                                            let
                                                user =
                                                    s.user
                                            in
                                            Just { s | user = { user | localisation = Just l } }

                                        _ ->
                                            Nothing
                            in
                            ( { model | session = session }, Cmd.none )

                        _ ->
                            ( { model | message = Just "Error while saving localisation. Try again" }, Cmd.none )

                _ ->
                    ( { model | message = Just "Error while saving localisation. Try again" }, Cmd.none )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location

                session =
                    model.session

                newModel =
                    oldModel
            in
            case session of
                Nothing ->
                    case newRoute of
                        Connect a ->
                            ( { newModel | route = Debug.log "newRoute" newRoute }, Cmd.none )

                        _ ->
                            ( newModel, Cmd.none )

                Just s ->
                    case newRoute of
                        TalksRoute ->
                            ( { newModel | route = newRoute }, getTalks s.token )

                        TalkRoute a ->
                            ( { newModel | route = newRoute }, getTalk a True s.token )

                        UsersRoute a ->
                          let
                            likeNotif =
                              if a == "likers" then 0 else model.notifLike
                            visitNotif =
                              if a == "visitors" then 0 else model.notifVisit
                          in
                            ( { newModel | route = newRoute, notifLike = likeNotif, notifVisit = visitNotif }, getRelevantUsers a s.token )

                        UserRoute a ->
                            ( { newModel | route = newRoute, current_user = findUserByName a model.users }, Cmd.none ) --getUser a s.token )

                        AccountRoute ->
                            ( { newModel | route = newRoute, map_state = Models.Loading }, Cmd.none )

                        EditAccountRoute ->
                            ( { newModel | route = newRoute, editAccountForm = initEditAccountForm s.user }, Cmd.none )

                        _ ->
                            ( { newModel | route = newRoute }, Cmd.none )

        GoBack amount ->
            ( model, Navigation.back amount )

        UpdateLoginForm id value ->
            let
                form =
                    model.loginForm

                newForm =
                    updateInput form id (Just value)
            in
            ( { model | loginForm = newForm }, Cmd.none )

        UpdateResetPwdForm id value ->
            let
                form =
                    model.resetPwdForm

                newForm =
                    updateInput form id (Just value)
            in
            ( { model | resetPwdForm = newForm }, Cmd.none )

        UpdateNewUserForm id value ->
            let
                form =
                    model.newUserForm

                newForm =
                    updateInput form id (Just value)
            in
            ( { model | newUserForm = newForm }, Cmd.none )

        SendLogin ->
            let
                values =
                    List.map (\i -> i.status) model.loginForm
            in
            case values of
                [ Valid a, Valid b ] ->
                    ( model, sendLogin a b )

                _ ->
                    ( model, Cmd.none )

        ResetPwd ->
            let
                values =
                    List.map (\i -> i.status) model.resetPwdForm
            in
            case values of
                [ Valid a, Valid b ] ->
                    ( model, resetPwd a b )

                _ ->
                    ( model, Cmd.none )

        NewUser ->
            let
                values =
                    List.map (\i -> i.status) model.newUserForm
            in
            case values of
                [ Valid username, Valid fname, Valid lname, Valid email, Valid pwd, Valid repwd ] ->
                    ( model, sendFastNewUser username fname lname email pwd repwd )

                _ ->
                    ( model, Cmd.none )

        ToggleLike username ->
            ( model, doIfConnected <| toggleLike username )

        SaveLocation ->
            case model.current_location of
                Just l ->
                    ( model, doIfConnected <| saveLocation l )

                _ ->
                    ( model, Cmd.none )

        UpdateNewMessage msg ->
            case ( model.route ) of
                ( TalkRoute u ) ->
                    let
                        newTalk =
                            case getTalkWith u model.talks of
                                Just t ->
                                    Just { t | new_message = msg }

                                _ ->
                                    Nothing

                        newTalks =
                            updateTalks newTalk model.talks
                    in
                    ( { model | talks = newTalks }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SendNewMessage ->
            case ( model.session, model.route ) of
                ( Just s, TalkRoute u ) ->
                    case getTalkWith u model.talks of
                        Just t ->
                            if String.trim t.new_message /= "" then
                                ( model, sendMessage s.token t.username_with t.new_message )
                            else
                                ( model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NewMessage str ->
            ( { model | message = Just str }, Cmd.none )

        FetchTalk a t ->
            case model.session of
                Just s ->
                    ( model, Cmd.none )

                _ ->
                    ( model, Navigation.newUrl "/#/login" )

        LoadMap t ->
            case ( model.map_state, model.route ) of
                ( Models.Loading, AccountRoute ) ->
                    let
                        cmd =
                            case model.session of
                                Just s ->
                                    case s.user.localisation of
                                        Just l ->
                                            localize [ l.lon, l.lat ]

                                        _ ->
                                            getIpLocalisation

                                _ ->
                                    Cmd.none
                    in
                    ( { model | map_state = Models.Rendered }, cmd )

                _ ->
                    ( model, Cmd.none )

        Localize ->
            ( model, getIpLocalisation )

        SetNewLocalisation loc ->
            case Debug.log "new loc" loc of
                [ long, lat ] ->
                    ( { model | current_location = Just <| Localisation long lat }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GetIpLocalisation resp ->
            case Debug.log "local" resp of
                Success locapi ->
                    let
                        loc =
                            case ( locapi.status, locapi.lon, locapi.lat ) of
                                ( "success", Just lo, Just la ) ->
                                    Just <| Localisation lo la

                                _ ->
                                    Nothing
                    in
                    ( { model | current_location = loc }
                    , localize <|
                        case loc of
                            Just l ->
                                [ l.lon, l.lat ]

                            _ ->
                                []
                    )

                _ ->
                    ( model, Cmd.none )

        UpdateEditAccountForm id value ->
            let
                form =
                    model.editAccountForm

                newForm =
                    updateInput form id (Just value)
            in
            ( { model | editAccountForm = newForm }, Cmd.none )

        UpdateAnim t ->
            let
                newAnim =
                    case model.matchAnim of
                        Just t ->
                            if (t - 0.01) > 0 then
                                Just (t - 0.01)
                            else
                                Nothing

                        _ ->
                            Nothing
            in
            ( { model | matchAnim = Debug.log "newAnim" newAnim }, Cmd.none )

        SaveAccountUpdates ->
            let
                values =
                    List.map (\i -> i.status) model.editAccountForm

                cmd =
                    case values of
                        [ Valid fname, Valid lname, Valid email, Valid bio ] ->
                            doIfConnected <| updateAccountInfos fname lname email bio

                        _ ->
                            Cmd.none
            in
            ( model, cmd )

        UpdateEditPwdForm id value ->
            let
                form =
                    model.changePwdForm

                newForm =
                    updateInput form id (Just value)
            in
            ( { model | changePwdForm = newForm }, Cmd.none )

        ChangePwd ->
            let
                values =
                    List.map (\i -> i.status) model.changePwdForm

                cmd =
                    case values of
                        [ Valid oldPwd, Valid newPwd, Valid confirmNewPwd ] ->
                            doIfConnected <| changePwd oldPwd newPwd confirmNewPwd

                        _ ->
                            Cmd.none
            in
            ( model, cmd )

        UpdateGender gender ->
            ( model, doIfConnected <| updateField gender )

        UpdateIntIn genders ->
            ( model, doIfConnected <| updateIntIn genders )

        SearchTag search ->
            case ( model.session, String.length search > 1, validTag <| Just search ) of
                ( Just s, True, Valid t ) ->
                    ( { model | tagInput = t }, searchTag s.token search )

                _ ->
                    ( { model | searchTag = [] }, Cmd.none )

        AddTag t ->
            ( model, doIfConnected (addTag t) )

        AddNewTag ->
            case validTag <| Just model.tagInput of
                Valid s ->
                    ( model, doIfConnected (addTag s) )

                _ ->
                    ( model, Cmd.none )

        RemoveTag t ->
            ( model, doIfConnected <| removeTag t )

        ImageSelected ->
            ( model, fileSelected model.idImg )

        ImageRead data ->
            let
                newImage =
                    { contents = data.contents
                    , filename = data.filename
                    }
            in
            ( { model | mImage = Just newImage }
            , doIfConnected <| uploadImage data.contents
            )

        DeleteImg id_ ->
            ( model, doIfConnected <| delImg id_ )

        SetCurrentTime t ->
            ( { model | currentTime = t }, Cmd.none )

        UpdateCurrentTime t ->
            ( model, now )

        Notification str ->
            case ( Json.Decode.decodeString notificationDecoder str, model.session ) of
                ( Ok notif, Just s ) ->
                    case notif.type_ of
                        NotifMessage ->
                            let
                                update =
                                    if model.route == TalkRoute notif.from || model.route == TalkRoute notif.to then
                                        True
                                    else
                                        False
                            in
                            if notif.to == s.user.username then
                                ( model, Cmd.batch [ getTalk notif.from update s.token, getTalks s.token ] )
                            else if notif.from == s.user.username then
                                ( model, getTalk notif.to update s.token )
                            else
                                ( model, Cmd.none )

                        NotifLike ->
                          if (notif.to == s.user.username && model.route /= UsersRoute "likers") then
                            ( { model | notifLike = notif.notif }, Cmd.none )
                          else if (notif.to == s.user.username && model.route == UsersRoute "likers") then
                            ( model, getRelevantUsers "likers" s.token )
                          else
                              ( model, Cmd.none )

                        NotifVisit ->
                            if (notif.to == s.user.username && model.route /= UsersRoute "visitors") then
                              ( { model | notifVisit = notif.notif }, Cmd.none )
                            else if (notif.to == s.user.username && model.route == UsersRoute "visitors") then
                              ( model, getRelevantUsers "visitors" s.token )
                            else
                                ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


now : Cmd Msg
now =
    Task.perform (Just >> SetCurrentTime) Time.now
