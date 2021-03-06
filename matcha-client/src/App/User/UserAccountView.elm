module App.User.UserAccountView exposing (view)

import App.AppModels exposing (..)
import App.User.UserModel exposing (..)
import FormUtils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed exposing (..)
import Json.Decode as JD
import Models exposing (..)
import Msgs exposing (..)
import Utils exposing (..)


view : Session -> AppModel -> List (Html Msg)
view session model =
    let
        shortBio =
          case session.user.bio of
            Just bio ->
              if String.length bio == 0 then
                  span [class "text-warning pointer", onClick ToggleAccountForm] [text "Please add a bio"]
              else if String.length bio < 50 then
                  text bio
              else
                  text <| String.left 50 bio ++ "..."
            _ -> span [class "text-warning pointer", onClick ToggleAccountForm] [text "Please add a bio"]
    in
    if model.showAccountMenu then
        [ div [ style [ ( "width", "100%" ), ("padding", "14px") ] ]
            [ div []
              <| if model.showEditAccountForm then
                  [ viewEditAccountForm model.editAccountForm session.user]
              else
                [ h2 [] [ text session.user.username ]
                , Html.Keyed.node "username" [] [ ("usrn", text <| session.user.fname ++ " " ++ session.user.lname) ]
                , div [] [ text session.user.email ]
                , div [] [ shortBio ]
                , button [class "btn-no-style", onClick ToggleAccountForm] [  text "Edit infos" ]
                ]
            , div []
              [ if model.showResetPwdForm then
                  viewEditPwdForm model.changePwdForm
                else
                  button [class "btn-no-style", onClick ToggleResetPwdForm] [ text "Edit password" ]
              ]
            , viewDateOfBirthInput session.user
            , viewGenderForm session.user.gender
            , viewIntInForm session.user.intIn
            , viewTagSection model session.user
            , viewImages model session.user
            , viewLocalisation model
            , div [ onClick Logout, class "center logout-btn" ] [ text "Logout ", icon "fas fa-power-off" ]
            ]
        ]
    else
        []

viewInfosMessage : SessionUser -> Html Msg
viewInfosMessage user =
    div [ class "row" ]
        [ div [ class "twelve columns" ] <|
            [ div [] <|
                (if user.status == Incomplete then
                    [ div [] [ text "Please complete your profile" ] ]
                 else
                    []
                )
                    ++ (if user.status == ResetPassword then
                            [ div [] [ text "Don't forget to change your password" ] ]
                        else
                            []
                       )
            ]
        ]


getUserBio : SessionUser -> String
getUserBio user =
  case user.bio of
    Just bio -> bio
    _ -> ""

viewLocalisation : AppModel -> Html Msg
viewLocalisation model =
    div (if model.localizing then [class "localizing"] else [])
        [ h3 [] [text "Localisation"]
        , div [ id "map" ]
              [ if model.localizing && model.map_state == Rendered then
                  button [ class "map-btn", Html.Attributes.attribute "disabled" "disabled" ] [  Html.Keyed.node "loc" [ class "fas fa-spinner fa-pulse" ][] ]
                else if model.map_state == Rendered then
                  button [ onClick Localize, class "map-btn" ] [  Html.Keyed.node "nloc" [ class  "fas fa-location-arrow" ] [] ]
                else
                  div [] []
              ]
        ]


viewImages : AppModel -> SessionUser -> Html Msg
viewImages model user =
    div []
      [ h3 [] [text "Images"]
      , div [ class "row gallery" ]
        [ if List.length user.photos > 0 then
            Html.ul [ class "img-account-list" ] <|
                List.map
                    (\( id_, s, main ) ->
                        li []
                            [ div [ style [ ( "background", "url(" ++ s ++ ") center center no-repeat" ) ], class "img-box" ]
                                [ button [ class "del", onClickCustom True False (DeleteImg id_) ] [ icon "fas fa-times" ]
                                , button [ class "img-main", onClickCustom True False (UpdateMainImage id_ ) ]
                                        [ if main then
                                            Html.Keyed.node "main" [ class "fas fa-star" ] []
                                          else
                                            Html.Keyed.node "nomain" [ class "far fa-star" ] []
                                        ]
                                ]
                            ]
                    )
                    user.photos
          else
            div [class "center text-warning"] [ text "You haven't uploaded any pictures yet" ]
        , if List.length user.photos < 5 then
            viewNewImgeForm model
          else
            div [] []
        ]
      ]


viewNewImgeForm : AppModel -> Html Msg
viewNewImgeForm model =
    let
        imagePreview =
            case model.mImage of
                Just i ->
                    viewImagePreview i

                Nothing ->
                    text ""
    in
    div [ class "imageWrapper center" ]
        [ label [ for model.idImg, class "label-upload button" ]
            [ input
                [ type_ "file"
                , accept "image/*"
                , id model.idImg
                , on "change"
                    (JD.succeed ImageSelected)
                ]
                []
            , text "Upload new image"
            ]
        ]


viewImagePreview : Image -> Html Msg
viewImagePreview image =
    img
        [ src image.contents
        , title image.filename
        ]
        []


viewTagSection : AppModel -> SessionUser -> Html Msg
viewTagSection model user =
    div [ class "tag-section center" ] <|
      h3 [] [text "Tags"]
      ::
        List.map
            (\t ->
                div [ class "tag dismissable" ]
                    [ text t
                    , div [ class "del pointer", onClickCustom False True (RemoveTag t) ] [ icon "fas fa-times" ]
                    ]
            )
            (List.sort user.tags)
            ++ [ viewTagForm model ]


viewTagForm : AppModel -> Html Msg
viewTagForm model =
    div [ class "input", id "search-input" ]
        [ Html.form [] <|
            [ input [ type_ "text", onInput SearchTag, value model.tagInput ] []
            , button
                [ class "btn-no-style", onClickCustom True True AddNewTag, type_ "submit" ]
                [ text "+" ]
            , Html.ul [ class "search-list" ] <|
                List.map (\i -> li [ onClickCustom False True (AddTag i), class "pointer" ] [ text i ]) model.searchTag
            ]
            ++
            case validTag <| Just model.tagInput of
              NotValid err -> [ div [ class "input-tip"] [text err] ]
              _ -> []
        ]




viewGenderForm : Maybe Gender -> Html Msg
viewGenderForm gender =
    div [ class "center" ] <|
        h3 [] [ text "I am" ]
        ::
        (if gender == Nothing then [span [class "text-warning"] [text "Please select your gender"]] else [])
        ++
        [ div [ class "row" ]
            [ label
                [ for "gmale"
                , class <|
                    "gender-btn three columns"
                        ++ (if gender == Just M then
                                " active"
                            else
                                ""
                           )
                ]
                [ text "Male "
                , i [ class "fas fa-mars" ] []
                , input
                    [ name "gender"
                    , type_ "radio"
                    , id "gmale"
                    , onClickCustom False True (UpdateGender M)
                    , checked (gender == Just M)
                    ]
                    []
                ]
            , label
                [ for "gfemale"
                , class <|
                    "gender-btn three columns"
                        ++ (if gender == Just F then
                                " active"
                            else
                                ""
                           )
                ]
                [ text "Female "
                , i [ class "fas fa-venus" ] []
                , input
                    [ name "gender"
                    , type_ "radio"
                    , id "gfemale"
                    , onClickCustom False True (UpdateGender F)
                    , checked (gender == Just F)
                    ]
                    []
                ]
            , label
                [ for "gnb"
                , class <|
                    "gender-btn three columns"
                        ++ (if gender == Just NB then
                                " active"
                            else
                                ""
                           )
                ]
                [ text "Non-binary "
                , i [ class "fas fa-transgender-alt" ] []
                , input
                    [ name "gender"
                    , type_ "radio"
                    , id "gnb"
                    , onClickCustom False True (UpdateGender NB)
                    , checked (gender == Just NB)
                    ]
                    []
                ]
            , label
                [ for "go"
                , class <|
                    "gender-btn three columns"
                        ++ (if gender == Just O then
                                " active"
                            else
                                ""
                           )
                ]
                [ text "Other "
                , i [ class "fas fa-genderless" ] []
                , input
                    [ name "gender"
                    , type_ "radio"
                    , id "go"
                    , onClickCustom False True (UpdateGender O)
                    , checked (gender == Just O)
                    ]
                    []
                ]
            ]
        ]


viewIntInForm : List Gender -> Html Msg
viewIntInForm intIn =
    div [ class "center" ] <|
        h3 [] [ text "I am interested in" ]
        ::
        (if intIn == [] then [span [class "text-warning"] [text "Please select the gender(s) you like"] ] else [])
        ++
        [ div [ class "row" ]
            [ label
                [ for "imale"
                , class <|
                    "gender-btn three columns"
                        ++ (if List.member M intIn then
                                " active"
                            else
                                ""
                           )
                ]
                [ text "Males "
                , i [ class "fas fa-mars" ] []
                , input
                    [ name "intIn"
                    , type_ "checkbox"
                    , id "imale"
                    , onClickCustom False True (UpdateIntIn M)
                    , checked <| List.member M intIn
                    ]
                    []
                ]
            , label
                [ for "ifemale"
                , class <|
                    "gender-btn three columns"
                        ++ (if List.member F intIn then
                                " active"
                            else
                                ""
                           )
                ]
                [ text "Females "
                , i [ class "fas fa-venus" ] []
                , input
                    [ name "intIn"
                    , type_ "checkbox"
                    , id "ifemale"
                    , onClickCustom False True (UpdateIntIn F)
                    , checked <| List.member F intIn
                    ]
                    []
                ]
            , label
                [ for "inb"
                , class <|
                    "gender-btn three columns"
                        ++ (if List.member NB intIn then
                                " active"
                            else
                                ""
                           )
                ]
                [ text "Non-binaries "
                , i [ class "fas fa-transgender-alt" ] []
                , input
                    [ name "intIn"
                    , type_ "checkbox"
                    , id "inb"
                    , onClickCustom False True (UpdateIntIn NB)
                    , checked <| List.member NB intIn
                    ]
                    []
                ]
            , label
                [ for "io"
                , class <|
                    "gender-btn three columns"
                        ++ (if List.member O intIn then
                                " active"
                            else
                                ""
                           )
                ]
                [ text "Others "
                , i [ class "fas fa-genderless" ] []
                , input
                    [ name "intIn"
                    , type_ "checkbox"
                    , id "io"
                    , onClickCustom False True (UpdateIntIn O)
                    , checked <| List.member O intIn
                    ]
                    []
                ]
            ]
        ]


viewEditAccountForm : Form -> SessionUser -> Html Msg
viewEditAccountForm accountForm user =
    div [ class "edit-form" ]
        [ Html.form [] <|
            List.map (\i -> viewInput (UpdateEditAccountForm i.id) i) accountForm
                ++ [ input
                        [ onClickCustom True True SaveAccountUpdates
                        , class "important-font"
                        , type_ "submit"
                        , value "SAVE"
                        ]
                        []
                  , button [ onClickCustom True True ToggleAccountForm, class "btn-no-style", style [("padding","5px")] ] [ text "Cancel" ]
                  ]
        ]


viewDateOfBirthInput : SessionUser -> Html Msg
viewDateOfBirthInput user =
  div [ class "center" ] <|
    h3 [] [ text "Date of birth" ]
    ::
    (if user.date_of_birth == Nothing then
        [div [ class "text-warning" ][text "Please set your date of birth"]]
    else [])
    ++
    [ select [ onInput UpdateBirth ] <|
      option
          ([ value "NaN" ]
              ++ (if user.date_of_birth == Nothing then
                      [ Html.Attributes.attribute "selected" "selected" ]
                  else
                      []
                 )
          )
          [ text "No" ]
          :: List.map
              (\a ->
                  option
                      ([ value <| toString a ]
                          ++ (if user.date_of_birth == Just a then
                                  [ Html.Attributes.attribute "selected" "selected" ]
                              else
                                  []
                             )
                      )
                      [ text <| toString a ]
              )
              (List.range 1900 2000)
    ]


viewEditPwdForm : Form -> Html Msg
viewEditPwdForm formm =
    div [ class "edit-form" ]
        [ Html.form [] <|
            List.map (\i -> viewInput (UpdateEditPwdForm i.id) i) formm
                ++ [ input
                        [ onClickCustom True True ChangePwd
                        , class "important-font"
                        , type_ "submit"
                        , value "CHANGE PASSWORD"
                        ]
                        []
                   ]
        , button [ onClickCustom True True ToggleResetPwdForm ] [ text "Cancel" ]
        ]
