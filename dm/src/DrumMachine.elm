module DM exposing (..)
import Html exposing (Html, div, text, a)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import List exposing (map)
import Window
import Task
import Time
import Ports
import Array exposing (Array)
import Matrix exposing (Matrix, Row)

instruments = List.reverse ["kick", "snare", "rimshot", "hihat"]

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type alias Model = { width : Int, height : Int, matrix: Matrix }
type Msg =
  Play String
  | Tick Time.Time
  | Toggle String Int
  | Start


init : (Model, Cmd Msg)
init = (Model 0 0 (Matrix.init instruments 16), Cmd.none)


viewRow : (String, Array Int) -> Html Msg
viewRow (name, data) =
  let
    trigger = div [class "trigger step", onClick (Play name)] [text name]
    stepClass val = classList [("row step", True), ("active", val == 1)]
    viewStep step val = div [stepClass val, onClick (Toggle name step)] []
  in
    div [class "row"] (trigger :: (Array.toList (Array.indexedMap viewStep data)))

view : Model -> Html Msg
view model =
  let
    rows = map viewRow model.matrix.rows
  in
    div [id "dm-app"] [
      div [class "rows"] rows,
      viewTransport
    ]

viewTransport : Html Msg
viewTransport =
  div [class "transport"] [
    a [id "play", href "#", onClick Start] [text "Play"]
  ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Play name -> (model, Ports.play name)
    Tick time -> (model, Cmd.none)
    Toggle row step ->
      let
        toggle n = if n == 0 then 1 else 0
        matrix = Debug.log "matrix" (Matrix.set toggle row step model.matrix)
        updated = { model | matrix = matrix }
      in
        (updated, Cmd.none)
    Start -> (model, Cmd.none)

subscriptions model =
  Time.every (Time.second * 5) Tick
