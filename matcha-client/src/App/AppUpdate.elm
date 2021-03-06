module App.AppUpdate exposing (..)

import Api.ApiModel exposing (..)
import App.AppModels exposing (..)
import App.Notif.NotifDecoder exposing (..)
import App.Notif.NotifModel exposing (..)
import App.Talk.TalkCommands exposing (..)
import App.Talk.TalkModel exposing (..)
import App.Talk.TalkUtils exposing (..)
import App.User.UserCommands exposing (..)
import App.User.UserHelper exposing (..)
import App.User.UserModel exposing (..)
import App.Admin.AdminModel exposing (..)
import App.User.UserUpdate exposing (..)
import App.Admin.AdminCommands exposing (..)
import Dom
import Dom.Scroll as Scroll
import FormUtils exposing (..)
import Http
import Json.Decode
import Login.LoginCommands exposing (..)
import Login.LoginModels exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Ports exposing (..)
import RemoteData exposing (..)
import Routing exposing (parseAppLocation, parseLoginLocation)
import Task
import Time
import Utils exposing (..)


updateApp : Msg -> AppRoutes -> Session -> AppModel -> UsersModel -> TalksModel -> ( Model, Cmd Msg )
updateApp msg route session appModel usersModel talksModel =
    let
        model =
            Connected route session appModel usersModel talksModel

        disconnect =
            ( initialModel LoginRoute, Navigation.newUrl "/#/login" )
    in
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Logout ->
            ( initialModel LoginRoute, Cmd.batch [ Navigation.newUrl "/#/login", deleteSession (), logout session.token ] )

        ShowAdmin ->
            ( Admin session { initAdminModel | fetching = True }, fetchAdminUsers session.token 1 )

        NoDataApiResponse reponse ->
            case route of
                UsersRoute a ->
                    ( model, Cmd.batch [ getRelevantUsers a session.token, getTalks session.token ] )

                _ ->
                    ( model, Cmd.none )

        ChangePwdRespone response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.message ) of
                        ( True, _ ) ->
                            ( updateAlertMsg "The password was succefully updated" model, Navigation.newUrl "/#/users/all" )

                        ( False, Just msg ) ->
                            ( updateAlertMsg msg model, Cmd.none )

                        _ ->
                            ( updateAlertMsg "Network error. Please try again" model, Cmd.none )

                _ ->
                    ( updateAlertMsg "Network error. Please try again" model, Cmd.none )

        ReqTagResponse response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.data ) of
                        ( True, Just d ) ->
                            let
                                u =
                                    session.user

                                newUser =
                                    { u | tags = d }

                                newSession =
                                    { session | user = newUser }
                            in
                            ( updateSessionModel newSession model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                Err err ->
                    handleErrorRequest err model Cmd.none

        SearchTagResponse response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.data ) of
                        ( True, Just d ) ->
                            ( updateAppModel { appModel | searchTag = d } model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                Err err ->
                    handleErrorRequest err model Cmd.none

        UpdateFieldResponse response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.data, rep.message ) of
                        ( True, Just u, _ ) ->
                            let
                                cmd =
                                    case route of
                                        UsersRoute a ->
                                            getRelevantUsers a session.token

                                        _ ->
                                            Cmd.none
                            in
                            ( updateSessionModel { session | user = u } <| updateAppModel { appModel | mImage = Nothing } model, cmd )

                        ( False, _, Just msg ) ->
                            ( Connected route session { appModel | message = Just msg } usersModel talksModel, Cmd.none )

                        _ ->
                            ( Connected route session { appModel | message = Just "Network error. Please try again", mImage = Nothing } usersModel talksModel, Cmd.none )

                Err err ->
                    handleErrorRequest err model Cmd.none

        UsersResponse response ->
            handleApiResponse response (updateUsers usersModel) updateUsersModel "Impossible to retrieve users" Cmd.none (updateAppModel { appModel | fetching = False } model)

        SearchResponse response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.data, rep.message ) of
                        ( True, Just d, _ ) ->
                            if d == [] then
                                ( updateAlertMsg "No users found" model, Cmd.none )
                            else
                                ( Connected route session { appModel | message = Nothing } (updateUsers usersModel d) talksModel, Cmd.none )

                        ( False, _, Just msg ) ->
                            ( updateAlertMsg "Server error" model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                Err err ->
                    handleErrorRequest err model Cmd.none

        UserResponse response ->
            handleApiResponse response (updateUser usersModel) updateUsersModel "User not found" Cmd.none model

        LikeResponse user response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.data ) of
                        ( True, Just d ) ->
                            ( Connected route session { appModel | message = Nothing } (updateUser usersModel d) talksModel, Cmd.batch [ sendUnlikeNotif session.token user, sendLikeNotif session.token user ] )

                        ( False, _ ) ->
                            ( updateAlertMsg "Server error" model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                Err err ->
                    handleErrorRequest err model Cmd.none

        EditAccountResponse email fname lname bio response ->
            case response of
                Ok rep ->
                    case rep.status of
                        True ->
                            let
                                user =
                                    session.user

                                newUser =
                                    { user | email = email, fname = fname, lname = lname, bio = Just bio }
                            in
                            ( Connected route { session | user = newUser } { appModel | message = Just "Information saved", showEditAccountForm = False } usersModel talksModel, Cmd.none )

                        _ ->
                            ( Connected route session { appModel | message = rep.message } usersModel talksModel, Cmd.none )

                Err err ->
                    handleErrorRequest err model Cmd.none

        GetTalkResponse response ->
            handleApiResponse response (updateTalks talksModel) updateTalksModel "Talk not found" (Task.attempt (always NoOp) <| Scroll.toBottom "talk-list") model

        GetTalksResponse response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.data ) of
                        ( True, Just talks ) ->
                            ( Connected route session appModel usersModel { talksModel | talks = talks }, List.map (\t -> getTalk t.username_with (talksModel.currentTalk == Just t.username_with) session.token) talks |> Cmd.batch )

                        _ ->
                            ( Connected route session { appModel | message = Just "user not found" } usersModel talksModel, Navigation.newUrl "/#/users" )

                Err err ->
                    handleErrorRequest err model Cmd.none

        SaveLocRespone response ->
            case response of
                Ok rep ->
                    case ( rep.status, appModel.current_location ) of
                        ( True, Just l ) ->
                            let
                                user =
                                    session.user

                                newSession =
                                    { session | user = { user | localisation = l } }

                                cmd =
                                    case route of
                                        UsersRoute a ->
                                            getRelevantUsers a session.token

                                        _ ->
                                            Cmd.none
                            in
                            ( Connected route newSession { appModel | localizing = False } usersModel talksModel, cmd )

                        _ ->
                            ( Connected route session { appModel | message = Just "Error while saving localisation. Try again", localizing = False } usersModel talksModel, Cmd.none )

                Err err ->
                    handleErrorRequest err model Cmd.none

        OnLocationChange location ->
            let
                newRoute =
                    parseAppLocation location

                newModel =
                    { appModel | message = Nothing, showEmoList = False, showAccountMenu = False, showAdvanceFilters = False, search = initialSearchModel, showTalksList = False }
            in
            case newRoute of
                UsersRoute a ->
                    let
                        likeNotif =
                            if route == UsersRoute "likers" then
                                []
                            else
                                appModel.notifLike

                        unLikeNotif =
                            if route == UsersRoute "likers" then
                                []
                            else
                                appModel.notifUnlike

                        visitNotif =
                            if route == UsersRoute "visitors" then
                                []
                            else
                                appModel.notifVisit
                    in
                    ( Connected newRoute session { newModel | notifLike = likeNotif, notifVisit = visitNotif, notifUnlike = unLikeNotif, fetching = True } usersModel talksModel, getRelevantUsers a session.token )

                SearchRoute ->
                    ( Connected newRoute session newModel usersModel talksModel, Cmd.none )


                NotFoundAppRoute ->
                    ( Connected newRoute session newModel usersModel talksModel, Cmd.none )

        GoBack amount ->
            ( model, Navigation.back amount )

        ToggleLike username ->
            ( model, toggleLike username session.token )

        ShowUser username ->
            ( Connected route session { appModel | showTalksList = False, showAccountMenu = False } { usersModel | currentUser = Just username } talksModel, Cmd.batch [ sendVisitNotif session.token username, getUser username session.token ] )

        UnshowAll ->
            let
                curU =
                    if appModel.showTalksList || appModel.showAccountMenu then
                        usersModel.currentUser
                    else
                        Nothing
            in
            ( Connected route session { appModel | showTalksList = False, showAccountMenu = False, map_state = App.AppModels.NoMap } { usersModel | currentUser = curU } talksModel, Cmd.none )

        UpdateNewMessage msg ->
            case talksModel.currentTalk of
                Just u ->
                    let
                        newTalksModel =
                            case getTalkWith u talksModel.talks of
                                Just t ->
                                    updateTalks talksModel { t | new_message = msg }

                                _ ->
                                    talksModel
                    in
                    ( Connected route session appModel usersModel newTalksModel, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SendNewMessage ->
            case talksModel.currentTalk of
                Just u ->
                    case getTalkWith u talksModel.talks of
                        Just t ->
                            if String.trim t.new_message /= "" then
                                ( updateAppModel { appModel | showEmoList = False } model, sendMessage session.token t.username_with t.new_message )
                            else
                                ( model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NewMessage str ->
            ( Connected route session { appModel | message = Just str } usersModel talksModel, Cmd.none )

        FetchTalk a t ->
            ( model, Cmd.none )

        LoadMap t ->
            case appModel.map_state of
                App.AppModels.Loading ->
                    ( Connected route session { appModel | map_state = Rendered } usersModel talksModel, localize [ session.user.localisation.lon, session.user.localisation.lat ] )

                _ ->
                    ( model, Cmd.none )

        Localize ->
            ( Connected route session { appModel | localizing = True } usersModel talksModel, tryToLocalize () )

        LocalizeIp worked ->
            ( Connected route session { appModel | localizing = True } usersModel talksModel, getIpLocalisation )

        SaveLocalisation loc ->
            case loc of
                [ long, lat ] ->
                    ( Connected route session { appModel | current_location = Just <| Localisation long lat } usersModel talksModel, saveLocation (Localisation long lat) session.token )

                _ ->
                    ( model, Cmd.none )

        NewLoc loc ->
            case ( loc, appModel.map_state ) of
                ( [ long, lat ], App.AppModels.Rendered ) ->
                    ( Connected route session { appModel | current_location = Just <| Localisation long lat, localizing = False } usersModel talksModel, Cmd.batch [ localize [ long, lat ], saveLocation (Localisation long lat) session.token ] )

                ( [ long, lat ], _ ) ->
                    ( Connected route session { appModel | current_location = Just <| Localisation long lat, localizing = False } usersModel talksModel, saveLocation (Localisation long lat) session.token )

                _ ->
                    ( Connected route session { appModel | localizing = False } usersModel talksModel, Cmd.none )

        GetIpLocalisationResponse resp ->
            case resp of
                Success locapi ->
                    let
                        loc =
                            case ( locapi.status == "success", locapi.lon, locapi.lat ) of
                                ( True, Just lo, Just la ) ->
                                    Just <| Localisation lo la

                                _ ->
                                    Nothing

                        cmd =
                            case loc of
                                Just l ->
                                    if appModel.map_state == App.AppModels.Rendered then
                                        Cmd.batch [ localize [ l.lon, l.lat ], saveLocation (Localisation l.lon l.lat) session.token ]
                                    else
                                        saveLocation (Localisation l.lon l.lat) session.token

                                _ ->
                                    Cmd.none
                    in
                    ( Connected route session { appModel | current_location = loc, localizing = False } usersModel talksModel, cmd )

                _ ->
                    ( Connected route session { appModel | localizing = False } usersModel talksModel, Cmd.none )

        UpdateEditAccountForm id_ value ->
            let
                form_ =
                    appModel.editAccountForm

                newForm =
                    updateInput form_ id_ (Just value)
            in
            ( Connected route session { appModel | editAccountForm = newForm } usersModel talksModel, Cmd.none )

        UpdateAnim t ->
            let
                newAnim =
                    case appModel.matchAnim of
                        Just t ->
                            if (t - 0.01) > 0 then
                                Just (t - 0.01)
                            else
                                Nothing

                        _ ->
                            Nothing
            in
            ( Connected route session { appModel | matchAnim = newAnim } usersModel talksModel, Cmd.none )

        SaveAccountUpdates ->
            let
                values =
                    List.map (\i -> i.status) appModel.editAccountForm

                cmd =
                    case values of
                        [ Valid fname, Valid lname, Valid email, Valid bio ] ->
                            updateAccountInfos fname lname email bio session.token

                        _ ->
                            Cmd.none
            in
            ( model, cmd )

        UpdateEditPwdForm id_ value ->
            let
                form_ =
                    appModel.changePwdForm

                newForm =
                    updateInput form_ id_ (Just value)
            in
            ( Connected route session { appModel | changePwdForm = newForm } usersModel talksModel, Cmd.none )

        ChangePwd ->
            let
                values =
                    List.map (\i -> i.status) appModel.changePwdForm

                cmd =
                    case values of
                        [ Valid oldPwd, Valid newPwd, Valid confirmNewPwd ] ->
                            changePwd oldPwd newPwd confirmNewPwd session.token

                        _ ->
                            Cmd.none
            in
            ( model, cmd )

        UpdateGender gender ->
            ( model, updateGender gender session.token )

        UpdateIntIn gender ->
            let
                newIntIn =
                    if List.member gender session.user.intIn then
                        List.filter ((/=) gender) session.user.intIn
                    else
                        gender :: session.user.intIn
            in
            ( model, updateIntIn newIntIn session.token )

        SearchTag search ->
            case ( String.length search > 1, validTag <| Just search ) of
                ( True, Valid t ) ->
                    ( Connected route session { appModel | tagInput = search } usersModel talksModel, searchTag session.token search )

                ( _, NotValid err ) ->
                    ( Connected route session { appModel | tagInput = search } usersModel talksModel, searchTag session.token search )

                _ ->
                    ( Connected route session { appModel | tagInput = search } usersModel talksModel, Cmd.none )

        AddTag t ->
            ( Connected route session { appModel | tagInput = "", searchTag = [] } usersModel talksModel, addTag t session.token )

        AddNewTag ->
            case validTag <| Just appModel.tagInput of
                Valid s ->
                    ( Connected route session { appModel | tagInput = "", searchTag = [] } usersModel talksModel, addTag s session.token )

                _ ->
                    ( model, Cmd.none )

        RemoveTag t ->
            ( model, removeTag t session.token )

        ImageSelected ->
            ( model, fileSelected appModel.idImg )

        ImageRead data ->
            let
                newImage =
                    { contents = data.contents
                    , filename = data.filename
                    }
            in
            ( Connected route session { appModel | mImage = Just newImage } usersModel talksModel
            , uploadImage data.contents session.token
            )

        DeleteImg id_ ->
            ( model, delImg id_ session.token )

        SetCurrentTime t ->
            ( Connected route session { appModel | currentTime = t } usersModel talksModel, Cmd.none )

        UpdateCurrentTime t ->
            ( model, now )

        ToggleAccountMenu ->
            let
                newAcc =
                    not appModel.showAccountMenu

                mapStatus =
                    if newAcc then
                        App.AppModels.Loading
                    else
                        App.AppModels.NoMap
            in
            ( Connected route session { appModel | showAccountMenu = newAcc, showTalksList = False, map_state = mapStatus, showResetPwdForm = False, showEditAccountForm = False } usersModel talksModel, Cmd.none )

        ChangeImage user to ->
            let
                newUsers =
                    showImage to user usersModel.users
            in
            ( Connected route session appModel { usersModel | users = newUsers } talksModel, Cmd.none )

        GoTo url ->
            ( model, Navigation.newUrl url )

        ChangeSort s ->
            let
                orderSort =
                    if s == usersModel.userSort then
                        toggleOrder usersModel.orderSort
                    else
                        ASC
            in
            ( Connected route session appModel { usersModel | userSort = s, orderSort = orderSort } talksModel, Task.attempt (always NoOp) <| Scroll.toTop "main" )

        Notification str ->
            case Json.Decode.decodeString notificationDecoder str of
                Ok notif ->
                    case notif.type_ of
                        NotifMessage ->
                            let
                                update =
                                    if talksModel.currentTalk == Just notif.from || talksModel.currentTalk == Just notif.to then
                                        True
                                    else
                                        False
                            in
                            if notif.to == session.user.username then
                                ( model, Cmd.batch [ getTalk notif.from update session.token, getTalks session.token ] )
                            else if notif.from == session.user.username then
                                ( model, getTalk notif.to update session.token )
                            else
                                ( model, Cmd.none )

                        NotifLike ->
                            if notif.to == session.user.username && route /= UsersRoute "likers" then
                                ( Connected route session { appModel | notifLike = notif.notif } usersModel talksModel, Cmd.none )
                            else if notif.to == session.user.username && route == UsersRoute "likers" then
                                ( model, getRelevantUsers "likers" session.token )
                            else
                                ( model, Cmd.none )

                        NotifUnlike ->
                            if notif.to == session.user.username && route /= UsersRoute "likers" then
                                ( Connected route session { appModel | notifUnlike = notif.notif } usersModel talksModel, Cmd.none )
                            else if notif.to == session.user.username && route == UsersRoute "likers" then
                                ( Connected route session { appModel | notifUnlike = notif.notif } usersModel talksModel, getRelevantUsers "likers" session.token )
                            else
                                ( model, Cmd.none )

                        NotifVisit ->
                            if notif.to == session.user.username && route /= UsersRoute "visitors" then
                                ( Connected route session { appModel | notifVisit = notif.notif } usersModel talksModel, Cmd.none )
                            else if notif.to == session.user.username && route == UsersRoute "visitors" then
                                ( model, getRelevantUsers "visitors" session.token )
                            else
                                ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ToggleEmoList ->
            ( Connected route session { appModel | showEmoList = not appModel.showEmoList } usersModel talksModel, Cmd.none )

        AddEmo talk em ->
            case getTalkWith talk talksModel.talks of
                Just t ->
                    let
                        newTalk =
                            { t | new_message = t.new_message ++ " ::__" ++ em ++ "__::" }

                        newTalksModel =
                            updateTalks talksModel newTalk
                    in
                    ( Connected route session appModel usersModel newTalksModel, Task.attempt (always NoOp) (Dom.focus "input-msg") )

                _ ->
                    ( model, Cmd.none )

        UpdateTagFilter tag_ ->
            let
                filters =
                    updateFilterTag usersModel.userFilter tag_
            in
            ( Connected route session appModel { usersModel | userFilter = filters } talksModel, Cmd.none )

        UpdateMinAgeFilter age ->
            let
                filters =
                    case String.toInt age of
                        Ok a ->
                            updateMinAgeFilter usersModel.userFilter a

                        _ ->
                            List.filter (\f -> not <| isMinFilter f) usersModel.userFilter
            in
            ( Connected route session appModel { usersModel | userFilter = filters } talksModel, Cmd.none )

        UpdateMaxAgeFilter age ->
            let
                filters =
                    case String.toInt age of
                        Ok a ->
                            updateMaxAgeFilter usersModel.userFilter a

                        _ ->
                            List.filter (\f -> not <| isMaxFilter f) usersModel.userFilter
            in
            ( Connected route session appModel { usersModel | userFilter = filters } talksModel, Cmd.none )

        ToggleAdvanceFilters ->
            ( Connected route session { appModel | showAdvanceFilters = not appModel.showAdvanceFilters } usersModel talksModel, Cmd.none )

        ResetFilters ->
            ( Connected route session appModel { usersModel | userFilter = [] } talksModel, Cmd.none )

        UpdateLocFilter dist ->
            let
                filters =
                    case String.toFloat dist of
                        Ok d ->
                            updateLocFilter usersModel.userFilter d

                        _ ->
                            List.filter (\f -> not <| isLocFilter f) usersModel.userFilter
            in
            ( Connected route session appModel { usersModel | userFilter = filters } talksModel, Cmd.none )

        SetCurrentTalk talk ->
            ( Connected route session { appModel | showTalksList = False } { usersModel | currentUser = Nothing } { talksModel | currentTalk = Just talk }, getTalk talk True session.token )

        CloseCurrentTalk ->
            ( updateTalksModel { talksModel | currentTalk = Nothing } model, Cmd.none )

        ToggleTalksList ->
            ( Connected route session { appModel | showTalksList = not appModel.showTalksList, showAccountMenu = False } usersModel talksModel, Cmd.none )

        ReportUser user ->
            ( Connected route session appModel { usersModel | currentUser = Nothing } talksModel, reportUser user session.token )

        BlockUser user ->
            let
                cuT =
                    if talksModel.currentTalk == Just user then
                        Nothing
                    else
                        talksModel.currentTalk
            in
            ( Connected route session appModel { usersModel | currentUser = Nothing } { talksModel | currentTalk = cuT }, blockUser user session.token )

        AdvanceSearch ->
            ( model, searchUser appModel.search session.token )

        UpdateSearchLogin log ->
            let
                searchModel =
                    appModel.search

                newSearch =
                    { searchModel | login = log }
            in
            ( updateAppModel { appModel | search = newSearch } model, Cmd.none )

        UpdateSearchTags tag_ ->
            let
                searchModel =
                    appModel.search

                newTags =
                    if List.member tag_ searchModel.tags then
                        List.filter ((/=) tag_) searchModel.tags
                    else
                        tag_ :: searchModel.tags

                newSearch =
                    { searchModel | tags = newTags }
            in
            ( updateAppModel { appModel | search = newSearch } model, Cmd.none )

        UpdateMinYearSearch year ->
            let
                searchModel =
                    appModel.search

                newYear =
                    case String.toInt year of
                        Ok y ->
                            Just y

                        _ ->
                            Nothing

                newSearch =
                    { searchModel | yearMin = newYear }
            in
            ( updateAppModel { appModel | search = newSearch } model, Cmd.none )

        UpdateMaxYearSearch year ->
            let
                searchModel =
                    appModel.search

                newYear =
                    case String.toInt year of
                        Ok y ->
                            Just y

                        _ ->
                            Nothing

                newSearch =
                    { searchModel | yearMax = newYear }
            in
            ( updateAppModel { appModel | search = newSearch } model, Cmd.none )

        UpdateLocSearch loc ->
            let
                searchModel =
                    appModel.search

                newLoc =
                    case String.toInt loc of
                        Ok l ->
                            Just l

                        _ ->
                            Nothing

                newSearch =
                    { searchModel | loc = newLoc }
            in
            ( updateAppModel { appModel | search = newSearch } model, Cmd.none )

        ResetSearch ->
            ( Connected route session { appModel | search = initialSearchModel } initialUsersModel talksModel
            , if route == SearchRoute then
                Cmd.none
              else
                Navigation.newUrl "/#/search"
            )

        UpdateBirth date ->
            case String.toInt date of
                Ok d ->
                    let
                        user =
                            session.user

                        newUser =
                            { user | date_of_birth = Just d }
                    in
                    ( Connected route { session | user = newUser } appModel usersModel talksModel, updateDateOfBirth d session.token )

                _ ->
                    ( model, Cmd.none )

        UpdateMainImage id_ ->
            ( model, mainImg id_ session.token )

        ToggleAccountForm ->
            ( Connected route session { appModel | editAccountForm = initEditAccountForm session.user, showEditAccountForm = not appModel.showEditAccountForm, showResetPwdForm = False } usersModel talksModel, Cmd.none )

        ToggleResetPwdForm ->
            ( Connected route session { appModel | showResetPwdForm = not appModel.showResetPwdForm, showEditAccountForm = False } usersModel talksModel, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleApiResponse : Result Http.Error (ApiResponse (Maybe a)) -> (a -> b) -> (b -> Model -> Model) -> String -> Cmd Msg -> Model -> ( Model, Cmd Msg )
handleApiResponse response updateData successUpdate errorMsg cmd model =
    case response of
        Ok rep ->
            case ( rep.status, rep.data, rep.message ) of
                ( True, Just d, _ ) ->
                    ( successUpdate (updateData d) model, cmd )

                ( False, _, Just msg ) ->
                    ( updateAlertMsg msg model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Err err ->
            handleErrorRequest err model Cmd.none


handleErrorRequest : Http.Error -> Model -> Cmd Msg -> ( Model, Cmd Msg )
handleErrorRequest err model cmd =
    case err of
        Http.BadStatus s ->
            if s.status.code == 401 then
                ( NotConnected LoginRoute initialLoginModel, deleteSession () )
            else
                ( updateAlertMsg "Error server" model, Cmd.none )

        _ ->
            ( updateAlertMsg "Error server" model, Cmd.none )


updateAppModel : AppModel -> Model -> Model
updateAppModel newAppModel model =
    case model of
        Connected route session appModel usersModel talksModel ->
            Connected route session newAppModel usersModel talksModel

        _ ->
            model


updateSessionModel : Session -> Model -> Model
updateSessionModel newSessionModel model =
    case model of
        Connected route session appModel usersModel talksModel ->
            Connected route newSessionModel appModel usersModel talksModel

        _ ->
            model


updateUsersModel : UsersModel -> Model -> Model
updateUsersModel newUsers model =
    case model of
        Connected route session appModel usersModel talksModel ->
            Connected route session appModel newUsers talksModel

        _ ->
            model


updateTalksModel : TalksModel -> Model -> Model
updateTalksModel newTalks model =
    case model of
        Connected route session appModel usersModel talksModel ->
            Connected route session appModel usersModel newTalks

        _ ->
            model


updateAlertMsg : String -> Model -> Model
updateAlertMsg msg model =
    case model of
        Connected route session appModel usersModel talksModel ->
            updateAppModel { appModel | message = Just msg } model

        _ ->
            model
