module DM exposing (..)
import Html exposing (Html, div, text, a)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import List exposing (map)
import Task
import Time
import Ports
import Array exposing (Array)
import Matrix exposing (Matrix, Row)

instruments = List.reverse ["kick", "snare", "rimshot", "hihat"]

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type alias AuClock
type alias Model = { width : Int, height : Int, matrix: Matrix, acTime: Float }

type Msg =
  Start
  | Stop
  | Play String
  | Tick Time.Time
  | Toggle String Int
  | AudioTime Float

init : (Model, Cmd Msg)
init =
  (Model 0 0 (Matrix.init instruments 16) 0, Cmd.none)


viewRow : Int -> (String, Array Int) -> Html Msg
viewRow currentStep (name, data) =
  let
    trigger = div [class "trigger step", onClick (Play name)] [text name]
    stepClass step val = classList [
      ("row step", True),
      ("active", val == 1),
      ("current", step == currentStep)
    ]
    viewStep step val = div [stepClass step val, onClick (Toggle name step)] []
  in
    div [class "row"] (trigger :: (Array.toList (Array.indexedMap viewStep data)))

view : Model -> Html Msg
view model =
  let
    rows = map (viewRow (Sched.currentStep model.sched)) model.matrix.rows
  in
    div [id "dm-app"] [
      div [class "rows"] rows,
      viewTransport model
    ]

viewTransport : Model -> Html Msg
viewTransport model =
  let ctrl = if Sched.isRunning model.sched
    then a [id "stop", href "#", onClick Stop] [text "Stop"]
    else a [id "play", href "#", onClick Start] [text "Play"]
  in
    div [class "transport"] [ ctrl ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Play name -> (model, play name 0)
    Tick time ->
      if Sched.isRunning model.sched
      then ({model | sched = Sched.tick time model.sched }, Cmd.none)
      else (model, Cmd.none)
    Toggle row step ->
      let
        toggle n = if n == 0 then 1 else 0
        matrix = Matrix.set toggle row step model.matrix
      in
        ({ model | matrix = matrix }, Cmd.none)
    AudioTime time ->
      ({ model | acTime = time }, Cmd.none)
    Start -> (model, Ports.getTime 0)
    Stop -> ({ model | acTime = 0 }, Cmd.none)

play : String -> Float -> Cmd Msg
play inst when = Ports.play (inst, when)

subscriptions model =
  Sub.batch [
    Time.every (Time.second / 30) Tick,
    Ports.currentTime AudioTime
  ]
