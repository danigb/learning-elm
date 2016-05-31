module DM exposing (..)
import Html exposing (Html)
import Html.App as App
import Html.Events exposing (onClick)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Window
import Task
import Time
import Ports

instruments = ["kick", "snare", "kick"]

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type alias Model = { width : Int, height : Int }
type Msg =
  Play String
  | Tick Time.Time

init : (Model, Cmd Msg)
init =
  ((Model 0 0), Cmd.none)

viewRow : Int -> String -> Html Msg
viewRow pos instr =
  let
    ypx = (toString (50 * pos)) ++ "px"
  in
    Svg.rect [x "0", y ypx, width "40px", height "40px", onClick (Play instr)] []

view : Model -> Html Msg
view m =
  let
    bg = Svg.rect [id "bg", x "0", y "0", width "100%", height "100%"] []
    rows = List.indexedMap viewRow instruments
  in
    Svg.svg [id "dm-app"] (bg :: rows)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Play name -> (model, Ports.play name)
    Tick time -> (model, Cmd.none)

subscriptions model =
  Time.every (Time.second * 5) Tick
