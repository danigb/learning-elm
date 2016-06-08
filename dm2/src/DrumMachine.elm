module DrumMachine exposing (..)
import Html exposing (Html, div, text)
import Html.App as App
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import String
import Array exposing (Array)
import Maybe exposing (withDefault)
import Time exposing (Time)

import Ports

type alias Tempo = Float
type alias Sched = { running: Bool, startAt: Time, rate: Float }
sched running startAt =
  Sched running startAt (Time.second / 10)

timeToBeat : Tempo -> Time -> Time -> Int
timeToBeat tempo start time =
  let
    elapsed = time - start
    beat = (60000 / tempo)
  in
    round (elapsed / beat)

beatToTime : Tempo -> Int -> Time
beatToTime tempo beat =
  (toFloat beat) * (60000 / tempo)

main =
  App.program { init = init, view = view, update = update, subscriptions = subs }

type alias Model = { tempo: Tempo, current: Int, patterns: List (Array String), audioStartAt: Float, sched: Sched }
init : (Model, Cmd Msg)
init =
  (Model 100 -1 [
    (pttrn "h...h...h.h...h."),
    (pttrn "..s...s...s..ss."),
    (pttrn "k...kk..k...k..k")
  ] 0 (sched False 0), Cmd.none)

type Msg =
  ToggleStep (Int, Int)
  | ToggleSched
  | Tick Time
  | SetAudioTime Float
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetAudioTime time ->
      ({ model | current = -1, sched = sched True 0, audioStartAt = Debug.log "audio" time }, Cmd.none)
    ToggleSched -> toggleSched model
    ToggleStep (row, step) ->
      ({ model | patterns = toggleStep row step model.patterns }, Cmd.none)
    Tick time -> tick time model

view : Model -> Html Msg
view model = viewMain model

subs : Model -> Sub Msg
subs model =
  let
    time = if model.sched.running then Time.every model.sched.rate Tick else Sub.none
    currentTime = Ports.currentAudioTime SetAudioTime
  in
    Sub.batch [time, currentTime]

-- UPDATES
toggleSched : Model -> (Model, Cmd Msg)
toggleSched model =
  if model.sched.running
    then ({ model | sched = sched False 0 }, Cmd.none)
    else (model, Ports.getAudioTime 0)

tick : Time -> Model -> (Model, Cmd Msg)
tick time model =
  if model.sched.startAt == 0
  then startSched time model
  else updateSched time model

startSched time model =
  ({ model | sched = sched True time, current = 0 }, schedule model 0)

updateSched time model =
  let
    toBeat = timeToBeat (model.tempo * 4) model.sched.startAt
    nextBeat = toBeat (time + 100)
    cmd = if model.current == nextBeat then Cmd.none else schedule model nextBeat
  in
    ({ model | current = (toBeat time) }, cmd)

schedule : Model -> Int -> Cmd Msg
schedule model beat =
  let
    beatTime = beatToTime (model.tempo * 4) beat
    audioTime = model.audioStartAt + (Time.inSeconds beatTime)
  in
    if beat % 4 == 0 then Ports.play (audioTime, "hi-hat") else Cmd.none

-- VIEWS
viewMain model =
  div [class "main"] [
    Html.h1 [onClick ToggleSched] [text "Tiny808"],
    div [class ""] (List.indexedMap (viewRow (model.current % 16)) model.patterns)
  ]

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


-- PATTERNS
letters = Array.fromList ["h", "s", "k"]
pttrn : String -> Array String
pttrn p = Array.fromList (String.split "" p)

toggleStep : Int -> Int -> List (Array String) -> List (Array String)
toggleStep row step patterns =
  List.indexedMap (\i p -> if i == row then (togglePtnStep row step p) else p) patterns

togglePtnStep : Int -> Int -> Array String -> Array String
togglePtnStep row step pattern =
  let
    letter = withDefault "x" (Array.get row letters)
    current = withDefault "." (Array.get step pattern)
    next = if current == "." then letter else "."
  in
    Array.set step next pattern
