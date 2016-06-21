module DrumMachine exposing (..)
import Html exposing (Html, div, text)
import Html.App as App
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)
import String
import Array exposing (Array)
import Maybe exposing (withDefault)
import Time exposing (Time)

import Ports

-- PATTERNS ----

instruments = Array.fromList ["cow-bell", "hi-hat", "snare", "kick"]
letters = Array.fromList ["b", "h", "s", "k"]
patterns = [
  (pttrn ".......b........"),
  (pttrn "h...h...h.h...h."),
  (pttrn "..ss..s...s..ss."),
  (pttrn "k...kk..k...k..k") ]


pttrn : String -> Array String
pttrn p = Array.fromList (String.split "" p)

toggleStep : Int -> Int -> List (Array String) -> List (Array String)
toggleStep row step patterns =
  List.indexedMap (\i p -> if i == row then (togglePtnStep row step p) else p) patterns

togglePtnStep : Int -> Int -> Array String -> Array String
togglePtnStep row step pattern =
  let
    current = withDefault "." (Array.get step pattern)
    rowLetter = withDefault "x" (Array.get row letters)
    next = if current == "." then rowLetter else "."
  in
    Array.set step next pattern

-- Time meter ------------
type alias Tempo = Float
type alias Meter = { tempo: Tempo, beats: Int, div: Int }

steps : Meter -> Int
steps meter =
  meter.beats * meter.div

stepLength : Meter -> Time
stepLength meter =
  (60000 / (meter.tempo * toFloat meter.div))

timeToStep: Meter -> Time -> Int
timeToStep meter time =
  floor (time / stepLength meter)

stepToTime : Meter -> Int -> Time
stepToTime meter num =
  (toFloat num) * (stepLength meter)
-------------------------

-- StepSequencer: the scheduler ---
type alias AudioTime = Float -- Audio time is expressed in seconds
type alias StepSeq = { running: Bool, nextStep: Int, startedAt: Time, audioTime: AudioTime }
type alias Schedule = { step: Int, audioTime: AudioTime }

stepSeq : StepSeq
stepSeq =
  StepSeq False 0 0 0

start : Time -> AudioTime -> StepSeq -> StepSeq
start time audioTime seq =
  { seq | running = True, startedAt = time + 100, audioTime = audioTime + 0.1 }

tick : Meter -> Time -> StepSeq -> (Maybe Schedule, StepSeq)
tick meter time seq =
  let
    elapsed = time - seq.startedAt
    nextEvent = stepToTime meter seq.nextStep
    sched = Schedule seq.nextStep (Time.inSeconds nextEvent + seq.audioTime)
  in
    if (elapsed + 200) < nextEvent
      then (Maybe.Nothing, seq)
      else (Maybe.Just sched, { seq | nextStep = seq.nextStep + 1 })
----------------
-- MODEL -----
type alias Model = { meter: Meter, current: Maybe Int, patterns: List (Array String), seq: StepSeq }
init : (Model, Cmd Msg)
init =
  (Model (Meter 100 4 4) Maybe.Nothing patterns stepSeq, Cmd.none)
getCurrent : Model -> Int
getCurrent model =
  case model.current of
    Maybe.Nothing -> -1
    Maybe.Just x -> x % (steps model.meter)

-- UPDATES ----
type Msg =
  Start
  | Stop
  | ToggleStep (Int, Int)
  | Tick Time
  | SetTime (Float, Float)
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetTime (time, audioTime) ->
      ({ model | seq = start time audioTime model.seq }, Cmd.none)
    Start -> (model, Ports.getAudioTime 0)
    Stop -> ({ model | seq = stepSeq, current = Maybe.Nothing }, Cmd.none)
    ToggleStep (row, step) ->
      ({ model | patterns = toggleStep row step model.patterns }, Cmd.none)
    Tick time -> onTick time model

view : Model -> Html Msg
view model =
  div [class "app"] [viewMain model]

subs : Model -> Sub Msg
subs model =
  let
    rate = Time.second / 10
    time = if model.seq.running then Time.every rate Tick else Sub.none
    currentTime = Ports.currentAudioTime SetTime
  in
    Sub.batch [time, currentTime]

-- UPDATES
onTick : Time -> Model -> (Model, Cmd Msg)
onTick time model =
  let
    current = timeToStep model.meter (time - model.seq.startedAt)
    (next, s) = tick model.meter time model.seq
    cmd = case next of
      Maybe.Nothing -> Cmd.none
      Maybe.Just x -> schedule model.patterns x
  in
    ({ model | seq = s, current = Maybe.Just current }, cmd)

schedule : List (Array String) -> Schedule -> Cmd Msg
schedule patterns sched =
  let
    inst n = withDefault "none" (Array.get n instruments)
    col = List.map (\p -> withDefault "." (Array.get (sched.step % 16) p)) patterns
    stepToCmd step val = if val == "." then Cmd.none else Ports.play (sched.audioTime, inst step)
  in
    Cmd.batch (List.indexedMap stepToCmd col)

-- VIEWS
viewMain model =
  div [class "main"] [
    Html.h1 [] [text "Elm Drum Machine"],
    div [class ""] (List.indexedMap (viewRow (getCurrent model)) model.patterns),
    viewTranport model
  ]

viewTranport model =
  let
    btn = if model.seq.running
      then Html.a [href "#", class "stop", onClick Stop] [text "Stop"]
      else Html.a [href "#", class "start", onClick Start] [text "Start"]
  in
    div [class "transport"] [ btn ]

viewRow : Int -> Int -> Array String -> Html Msg
viewRow current row pattern =
  div [class "row"] (List.indexedMap (viewStep current row) (Array.toList pattern))

viewStep : Int -> Int -> Int -> String -> Html Msg
viewStep current row step value =
  let
    classes = classList [
      ("step", True),
      ("active", value /= "."),
      ("current", current == step)
    ]
  in
    div [classes, onClick (ToggleStep (row, step))] [text value]


-- MAIN ----
main =
  App.program { init = init, view = view, update = update, subscriptions = subs }
