module AppUpdate exposing (..)

import Commands exposing (..)
import Dom
import Dom.Scroll as Scroll
import FormUtils exposing (..)
import Json.Decode
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (..)
import Notif.NotifDecoder exposing (..)
import Notif.NotifModel exposing (..)
import Ports exposing (..)
import RemoteData exposing (..)
import Routing exposing (parseAppLocation, parseLoginLocation)
import Talk.TalkCommands exposing (..)
import Talk.TalkModel exposing (..)
import Talk.TalkUtils exposing (..)
import Task
import Time
import User.UserCommands exposing (..)
import User.UserHelper exposing (..)
import User.UserModel exposing (..)
import User.UserUpdate exposing (..)
import Utils exposing (..)

updateAppModel : Msg -> AppRoutes -> Session -> AppModel -> (Model, Cmd Msg)
updateAppModel msg route session appModel =
  let
    model = Connected route session appModel
    disconnect = ( initialModel LoginRoute, Navigation.newUrl "/#/login" )
  in
    case msg of
        NoOp ->
            ( Connected route session appModel, Cmd.none )

        Logout ->
            ( initialModel LoginRoute, Cmd.batch [ Navigation.newUrl "/#/login", deleteSession () ] )

        ChangePwdRespone response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.message ) of
                        ( "success", _ ) ->
                            ( Connected route session { appModel | message = Just "The password was succefully updated" }, Navigation.newUrl "/#/account" )

                        ( "error", Just msg ) ->
                            ( Connected route session { appModel | message = Just msg }, Cmd.none )

                        _ ->
                            ( Connected route session { appModel | message = Just "Network error. Please try again" }, Cmd.none )

                _ ->
                    ( Connected route session { appModel | message = Just "Network error. Please try again" }, Cmd.none )

        ReqTagResponse response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.data ) of
                        ( "success", Just d ) ->
                            let
                                u =
                                    session.user

                                newUser =
                                    { u | tags = d }

                                newSession =
                                    { session | user = newUser }
                            in
                            ( Connected route newSession appModel, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SearchTagResponse response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.data ) of
                        ( "success", Just d ) ->
                            ( Connected route session { appModel | searchTag = d }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UpdateFieldResponse token response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.data, rep.message ) of
                        ( "success", Just u, _ ) ->
                            ( Connected route { session | user = u, token = token } { appModel | mImage = Nothing }, Cmd.none )

                        ( "error", _, Just msg ) ->
                            ( Connected route session { appModel | message = Just msg }, Cmd.none )

                        _ ->
                            ( Connected route session { appModel | message = Just "Network error. Please try again", mImage = Nothing }, Cmd.none )

                _ ->
                    ( Connected route session { appModel | message = Just "Network error. Please try again", mImage = Nothing }, Cmd.none )

        UsersResponse response ->
            case response of
                Ok rep ->
                    case ( rep.status == "success", rep.data ) of
                        ( True, Just u ) ->
                            ( Connected route session { appModel | users = u }, Cmd.none )

                        _ ->
                            ( Connected route session { appModel | message = Just "Network errror. Please try again" }, Cmd.none )

                _ ->
                    ( Connected route session { appModel | message = Just "Network error. Please try again" }, Cmd.none )


        UserResponse response ->
            case Debug.log "User" response of
                Ok rep ->
                    case ( rep.status == "success", rep.data ) of
                        ( True, Just u ) ->
                            ( Connected route session { appModel | users = updateUser u appModel.users }, Cmd.none )

                        _ ->
                            ( Connected route session { appModel | message = Just "User not found" }, Cmd.none )

                _ ->
                    disconnect

        EditAccountResponse email fname lname bio response ->
            case response of
                Ok rep ->
                    case rep.status of
                        "success" ->
                            let
                                user =
                                    session.user

                                newUser =
                                    { user | email = email, fname = fname, lname = lname, bio = bio }
                            in
                            ( Connected route { session | user = newUser } { appModel | message = Just "Information saved" }, Navigation.newUrl "/#/account" )

                        _ ->
                            ( Connected route session { appModel | message = rep.message }, Cmd.none )

                _ ->
                    disconnect



        GetTalkResponse response ->
            case response of
                Ok rep ->
                    case ( rep.status, rep.data ) of
                        ( "success", talk ) ->
                            ( Connected route session { appModel | talks = updateTalks talk appModel.talks }, Task.attempt (always NoOp) <| Scroll.toBottom "talk-list" )

                        _ ->
                            ( Connected route session { appModel | message = Just "user not found" }, Navigation.newUrl "/#/users" )

                _ ->
                    disconnect

        GetTalksResponse response ->
            case response of
                Ok rep ->
                    case ( rep.status == "success", rep.data ) of
                        ( True, Just talks ) ->
                            ( Connected route session { appModel | talks = talks }, List.map (\t -> getTalk t.username_with (route == TalkRoute t.username_with) session.token) talks |> Cmd.batch )

                        _ ->
                            ( Connected route session { appModel | message = Just "user not found" }, Navigation.newUrl "/#/users" )

                _ ->
                    disconnect

        SaveLocRespone response ->
            case response of
                Ok rep ->
                    case ( rep.status, appModel.current_location ) of
                        ("success", Just l) ->
                            let
                                user = session.user
                                newSession = { session | user = { user | localisation = l } }
                            in
                                ( Connected route newSession appModel, Cmd.none )

                        _ ->
                            ( Connected route session { appModel | message = Just "Error while saving localisation. Try again" }, Cmd.none )

                _ ->
                  ( Connected route session { appModel | message = Just "Error while saving localisation. Try again" }, Cmd.none )


        OnLocationChange location ->
            let
                newRoute =
                    parseAppLocation location

                newModel =
                    { appModel | message = Nothing, showEmoList = False, showAccountMenu = False, showAdvanceFilters = False }
            in
              case newRoute of
                        TalksRoute ->
                            ( Connected newRoute session newModel, getTalks session.token )

                        TalkRoute a ->
                            ( Connected newRoute session newModel, getTalk a True session.token )

                        UsersRoute a ->
                            let
                                likeNotif =
                                    if a == "likers" then
                                        0
                                    else
                                        appModel.notifLike

                                visitNotif =
                                    if a == "visitors" then
                                        0
                                    else
                                        appModel.notifVisit
                            in
                            ( Connected newRoute session { newModel | notifLike = likeNotif, notifVisit = visitNotif }, getRelevantUsers a session.token )

                        UserRoute a ->
                            ( Connected newRoute session newModel, Cmd.batch [ sendVisitNotif session.token a, getUser a session.token ] )

                        AccountRoute ->
                            ( Connected newRoute session { newModel | map_state = Models.Loading }, Cmd.none )

                        EditAccountRoute ->
                            ( Connected newRoute session { newModel | editAccountForm = initEditAccountForm session.user }, Cmd.none )

                        ChangePwdRoute ->
                          ( Connected newRoute session newModel, Cmd.none )

                        NotFoundAppRoute ->
                          ( Connected newRoute session newModel, Cmd.none )


        GoBack amount ->
            ( model, Navigation.back amount )


        ToggleLike username ->
            ( model, toggleLike username session.token )

        UpdateNewMessage msg ->
            case route of
                TalkRoute u ->
                    let
                        newTalk =
                            case getTalkWith u appModel.talks of
                                Just t ->
                                    Just { t | new_message = msg }

                                _ ->
                                    Nothing

                        newTalks =
                            updateTalks newTalk appModel.talks
                    in
                    ( Connected route session { appModel | talks = newTalks }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SendNewMessage ->
            case route of
                TalkRoute u ->
                    case getTalkWith u appModel.talks of
                        Just t ->
                            if String.trim t.new_message /= "" then
                                ( model, sendMessage session.token t.username_with t.new_message )
                            else
                                ( model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NewMessage str ->
            ( Connected route session { appModel | message = Just str }, Cmd.none )

        FetchTalk a t ->
            ( model, Cmd.none )

        LoadMap t ->
            case ( appModel.map_state, route ) of
                ( Models.Loading, AccountRoute ) ->
                    ( Connected route session { appModel | map_state = Models.Rendered }, localize [ session.user.localisation.lon, session.user.localisation.lat ] )

                _ ->
                    ( model, Cmd.none )

        Localize ->
            ( model, getIpLocalisation )

        SetNewLocalisation loc ->
            case loc of
                [ long, lat ] ->
                    ( Connected route session { appModel | current_location = Just <| Localisation long lat }, saveLocation (Localisation long lat) session.token )

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

                        cmd =
                            case loc of
                                Just l ->
                                    Cmd.batch [ localize [ l.lon, l.lat ], saveLocation (Localisation l.lon l.lat) session.token ]

                                _ ->
                                    Cmd.none
                    in
                    ( Connected route session { appModel | current_location = loc }, cmd )

                _ ->
                    ( model, Cmd.none )

        UpdateEditAccountForm id_ value ->
            let
                form_ =
                    appModel.editAccountForm

                newForm =
                    updateInput form_ id_ (Just value)
            in
            ( Connected route session { appModel | editAccountForm = newForm }, Cmd.none )

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
            ( Connected route session { appModel | matchAnim = Debug.log "newAnim" newAnim }, Cmd.none )

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
            ( Connected route session { appModel | changePwdForm = newForm }, Cmd.none )

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
            ( model, updateField gender session.token )

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
            case (String.length search > 1, validTag <| Just search ) of
                ( True, Valid t ) ->
                    ( Connected route session { appModel | tagInput = search }, searchTag session.token search )

                ( _, NotValid err ) ->
                    ( Connected route session { appModel | tagInput = search }, searchTag session.token search )

                _ -> ( model, Cmd.none )


        AddTag t ->
            ( Connected route session { appModel | tagInput = "", searchTag = [] }, (addTag t) session.token )

        AddNewTag ->
            case validTag <| Just appModel.tagInput of
                Valid s ->
                    ( Connected route session { appModel | tagInput = "", searchTag = [] }, (addTag s) session.token )

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
            ( Connected route session { appModel | mImage = Just newImage }
            ,  uploadImage data.contents session.token
            )

        DeleteImg id_ ->
            ( model, delImg id_ session.token )

        SetCurrentTime t ->
            ( Connected route session { appModel | currentTime = t }, Cmd.none )

        UpdateCurrentTime t ->
            ( model, now )

        ToggleAccountMenu ->
            ( Connected route session { appModel | showAccountMenu = not appModel.showAccountMenu }, Cmd.none )

        ChangeImage user to ->
            let
                newUsers =
                    showImage to user appModel.users
            in
            ( Connected route session { appModel | users = newUsers }, Cmd.none )

        GoTo url ->
            ( model, Navigation.newUrl url )

        ChangeSort s ->
            let
                orderSort =
                    if s == appModel.userSort then
                        toggleOrder appModel.orderSort
                    else if s == S_Afin then
                        ASC
                    else
                        DESC
            in
            ( Connected route session { appModel | userSort = s, orderSort = orderSort }, Cmd.none )

        Notification str ->
            case Json.Decode.decodeString notificationDecoder str of
                Ok notif ->
                    case notif.type_ of
                        NotifMessage ->
                            let
                                update =
                                    if route == TalkRoute notif.from || route == TalkRoute notif.to then
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
                                ( Connected route session { appModel | notifLike = notif.notif }, Cmd.none )
                            else if notif.to == session.user.username && route == UsersRoute "likers" then
                                ( model, getRelevantUsers "likers" session.token )
                            else
                                ( model, Cmd.none )

                        NotifVisit ->
                            if notif.to == session.user.username && route /= UsersRoute "visitors" then
                                ( Connected route session { appModel | notifVisit = notif.notif }, Cmd.none )
                            else if notif.to == session.user.username && route == UsersRoute "visitors" then
                                ( model, getRelevantUsers "visitors" session.token )
                            else
                                ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ToggleEmoList ->
            ( Connected route session { appModel | showEmoList = not appModel.showEmoList }, Cmd.none )

        AddEmo talk em ->
            case getTalkWith talk appModel.talks of
                Just t ->
                    let
                        newTalk =
                            { t | new_message = t.new_message ++ " ::__" ++ em ++ "__::" }

                        newTalks =
                            updateTalks (Just newTalk) appModel.talks
                    in
                    ( Connected route session { appModel | talks = newTalks }, Task.attempt (always NoOp) (Dom.focus "input-msg") )

                _ ->
                    ( model, Cmd.none )

        UpdateTagFilter tag_ ->
          let
            filters = updateFilterTag appModel.userFilter tag_
          in
            ( Connected route session { appModel | userFilter = Debug.log "filters" filters }, Cmd.none )

        UpdateMinAgeFilter age ->
          let filters =
            case String.toInt age of
              Ok a -> updateMinAgeFilter appModel.userFilter a
              _ -> List.filter (\f -> not <| isMinFilter f ) appModel.userFilter
          in
            ( Connected route session { appModel | userFilter = Debug.log "filters" filters }, Cmd.none )

        UpdateMaxAgeFilter age ->
          let filters =
            case String.toInt age of
              Ok a -> updateMaxAgeFilter appModel.userFilter a
              _ -> List.filter (\f -> not <| isMaxFilter f ) appModel.userFilter
          in
            ( Connected route session { appModel | userFilter = Debug.log "filters" filters }, Cmd.none )

        ToggleAdvanceFilters ->
          ( Connected route session { appModel | showAdvanceFilters = not appModel.showAdvanceFilters }, Cmd.none )

        ResetFilters ->
          ( Connected route session { appModel | userFilter = [] }, Cmd.none )

        UpdateLocFilter dist ->
          let
            filters =
              case String.toFloat dist of
                Ok d -> updateLocFilter appModel.userFilter d
                _ -> List.filter (\f -> not <| isLocFilter f ) appModel.userFilter
          in
            ( Connected route session { appModel | userFilter = Debug.log "filters" filters }, Cmd.none )

        _ -> ( model, Cmd.none )
