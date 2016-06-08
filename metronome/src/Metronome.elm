module Metronome exposing (..)

import Time exposing (Time, inSeconds)
import Html exposing (Html, div, text)
import Html.Attributes as A
import Html.Events exposing (onClick, onInput)
import Html.App as App
import String
import Ports

type alias Bpm = Float
type alias Meter = (Int, Int)
type alias Pos = { measure: Int, beat: Int, sub: Int }

type alias Model = {
  bpm: Bpm, meter: Meter, running: Bool, startTime : Maybe Time, current : Time, audioStartAt: Float, pos: Pos }
type Msg = Tick Time | Start | Stop | BpmChanged String | SetAudioTime Float

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

init : (Model, Cmd Msg)
init = (Model 120 (4, 4) False Maybe.Nothing 0 0 (Pos 0 0 0), Cmd.none)

view : Model -> Html Msg
view model =
  div [] [
    Html.h1 [] (if model.running then viewPos model.pos else [text "Press start"]),
    Html.h2 [] (if model.running then viewTime model.current else [text "h:m:s"]),
    Html.h3 [] [text ("Tempo: " ++ (toString model.bpm))],
    Html.input [A.type' "range", A.min "40", A.max "250", A.step "0.5",
                A.value (toString model.bpm), onInput BpmChanged] [],
    Html.h4 [] [text (toString model.meter)],
    Html.a [A.href "#", onClick Start] [text "Start"],
    Html.a [A.href "#", onClick Stop] [text "Stop"]
  ]

viewTime time =
  let
    h = floor (Time.inHours time)
    m = floor (Time.inMinutes time)
    s = floor (Time.inSeconds time)
  in
    [ span (toString h), span ":",
      span (toString m), span ":",
      span (toString s) ]

span t = Html.span [] [text t]

viewPos pos =
  [ span (toString pos.measure), span ".",
    span (toString (pos.beat + 1)), span ".",
    span (toString (pos.sub + 1)) ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Start -> (model, Ports.getAudioTime 0)
    Stop -> ({ model | running = False, startTime = Maybe.Nothing }, Cmd.none)
    Tick time -> tick time model
    BpmChanged newBpm -> ({ model | bpm = Result.withDefault 120 (String.toFloat newBpm) }, Cmd.none)
    SetAudioTime time -> ({ model | running = True, audioStartAt = time }, Ports.click (time, "high"))

tick : Time -> Model -> (Model, Cmd Msg)
tick time model =
  let
    elapsed = time - Maybe.withDefault time model.startTime
    updated = case model.startTime of
      Maybe.Nothing -> { model | startTime = Maybe.Just time, pos = Pos 0 0 0 }
      Maybe.Just start -> { model | pos = position model.bpm model.meter elapsed, current = elapsed }
    nextMeasure = Pos (updated.pos.measure + 1) 0 0
    nmTime = toTime model.bpm model.meter nextMeasure
    nbTime = toTime model.bpm model.meter (Pos updated.pos.measure (updated.pos.beat + 1) 0)
    tickSecs = Time.second / 30
    cmd = if nmTime - elapsed <= tickSecs then Ports.click (model.audioStartAt + nmTime, "high")
      else if nbTime - elapsed <= tickSecs then Ports.click (model.audioStartAt + nbTime, "low")
      else Cmd.none
  in
    (updated, cmd)

position : Bpm -> Meter -> Float -> Pos
position bpm (n, d) secs =
  let
    s = if d == 4 then 4 else 3
    len = 60 / (bpm * (toFloat s))
    subs = floor (secs / len)
    beats = subs // s
  in
    Pos (beats // n) (beats % n) (subs % s)

toTime : Bpm -> Meter -> Pos -> Time
toTime bpm (n, d) pos =
  let
    s = if d == 4 then 4 else 3
    len = 60 / (bpm * (toFloat s))
    subs = toFloat ((pos.measure * n + pos.beat) * s + pos.sub)
  in
    len * subs

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch [subTime model, Ports.currentAudioTime SetAudioTime]

subTime : Model -> Sub Msg
subTime model =
  if model.running
    then Time.every (Time.second / 30) Tick
    else Sub.none
