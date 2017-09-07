import Html exposing (..)

type Msg =
 NoMsg

type alias Model = Int

type alias Flags =
    { users : String }

initModel : Flags -> (Model, Cmd Msg)
initModel flags =
    (0, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        NoMsg -> (model, Cmd.none)

view : Model -> Html Msg
view model =
 text "Salut"

main =
    Html.programWithFlags
    { init = initModel
    , subscriptions = subscriptions
    , view = view
    , update = update
    }
