module Metronome exposing (..)

import Time exposing (Time, inSeconds)
import Html exposing (Html, div, text, span)
import Html.Attributes as A
import Html.Events exposing (onClick, onInput)
import Html.App as App
import String

type alias Bpm = Float
type alias Meter = (Int, Int)
type alias Pos = { measure: Int, beat: Int, sub: Int }

type alias Model = {
  bpm: Bpm, meter: Meter, running: Bool, startTime : Maybe Time, pos: Pos }
type Msg = Tick Time | Start | Stop | BpmChanged String

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

init : (Model, Cmd Msg)
init = (Model 120 (4, 4) False Maybe.Nothing (Pos 0 0 0), Cmd.none)

view : Model -> Html Msg
view model =
  div [] [
    (if model.running then viewPos model.pos else div [] []),
    Html.h3 [] [text (toString model.bpm)],
    Html.input [A.type' "range", A.min "40", A.max "250", A.step "0.5",
                A.value (toString model.bpm), onInput BpmChanged] [],
    Html.h4 [] [text (toString model.meter)],
    Html.a [A.href "#", onClick Start] [text "Start"],
    Html.a [A.href "#", onClick Stop] [text "Stop"]
  ]

viewPos pos =
  Html.h1 [] [
    span [] [text (toString pos.measure)],
    span [] [text "."],
    span [] [text (toString (pos.beat + 1))],
    span [] [text "."],
    span [] [text (toString (pos.sub + 1))]
  ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Start -> ({ model | running = True }, Cmd.none)
    Stop -> ({ model | running = False, startTime = Maybe.Nothing }, Cmd.none)
    Tick time -> (tick time model, Cmd.none)
    BpmChanged newBpm -> ({ model | bpm = Result.withDefault 120 (String.toFloat newBpm) }, Cmd.none)

tick : Time -> Model -> Model
tick time model =
  case model.startTime of
    Maybe.Nothing -> { model | startTime = Maybe.Just time, pos = Pos 0 0 0 }
    Maybe.Just start -> { model | pos = position model.bpm model.meter start time }

position : Bpm -> Meter -> Time -> Time -> Pos
position bpm (n, d) start current =
  let
    len = 60 / (bpm * (toFloat d))
    subs = floor (inSeconds (current - start) / len)
    beats = subs // 4
  in
    Pos (beats // n) (beats % n) (subs % 4)

subscriptions : Model -> Sub Msg
subscriptions model =
  if model.running
    then Time.every (Time.second / 30) Tick
    else Sub.none
