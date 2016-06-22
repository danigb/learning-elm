import Html exposing (Html)
import Html.App as App
import Knob

type alias Model = { gain: Knob.Model, freq: Knob.Model }
type Msg = None

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

init : (Model, Cmd Msg)
init =
  ({
    gain = Knob.Model "Gain" 0 100 50 Nothing,
    freq = Knob.Model "Freq" 100 2000 440 Nothing
  }, Cmd.none)

view : Model -> Html Msg
view model =
  Html.div [] [
    Knob.view model.gain,
    Knob.view model.freq
  ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
