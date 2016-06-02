module DM exposing (..)
import Html exposing (Html, div, text)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import List exposing (map)
import Window
import Task
import Time
import Ports
import Array exposing (Array)

instruments = ["kick", "snare", "rimshot", "hihat"]

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type alias Model = { width : Int, height : Int, rows: List (String, Array Int) }
type Msg =
  Play String
  | Tick Time.Time
  | Toggle Int Int

initRow : Array Int
initRow = Array.fromList (List.repeat 16 0)

initModel : Model
initModel = Model 0 0 (map (\n -> (n, initRow)) instruments)

init : (Model, Cmd Msg)
init = (initModel, Cmd.none)


viewRow : Int -> (String, Array Int) -> Html Msg
viewRow pos (name, row) =
  let
    ypx = (toString (50 * pos)) ++ "px"
    trigger = div [class "trigger step", onClick (Play name)] [text name]
    viewStep step val = div [class "row step", onClick (Toggle pos step)] []
  in
    div [class "row"] (trigger :: (Array.toList (Array.indexedMap viewStep row)))

view : Model -> Html Msg
view m =
  let
    rows = List.indexedMap viewRow m.rows
  in
    div [id "dm-app"] [
      div [class "rows"] rows
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Play name -> (model, Ports.play name)
    Tick time -> (model, Cmd.none)
    Toggle row step ->
      let r = Debug.log "toggle" (List.head (List.drop row model.rows))
      in (model, Cmd.none)

subscriptions model =
  Time.every (Time.second * 5) Tick
