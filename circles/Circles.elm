module Circles exposing (..)
import Ports exposing (play)
import Html exposing (Html)
import Html.App as App
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json
import Time
import Random
import List exposing (head, drop, length)

type alias Circle = { x : Int, y : Int, r : Float, seed: Int }
type alias Model = { circles : List Circle, nextRand: Int }

colors : List String
colors = ["#DBFFF2", "#05668D", "#028090", "#00A896", "#02C39A", "#F0F3BD"]

pick : Int -> List String -> String
pick i list =
  case head (drop (i % length list) list) of
    Just x -> x
    Nothing -> ""

color : Circle -> String
color circle = pick circle.seed colors

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type Msg =
  AddCircle (Int, Int)
  | Tick Float
  | NewRand Int


genCmd : Cmd Msg
genCmd =
  Random.generate NewRand (Random.int 0 11)

init : (Model, Cmd Msg)
init =
  ({ circles = [], nextRand = 0 }, genCmd)

view : Model -> Html Msg
view model =
  let
    bg = Svg.rect [x "0", y "0", width "100%", height "100%", onClick ] []
    circles = List.map viewCircle model.circles
  in
    Svg.svg [id "circles-app"] (bg :: circles)

viewCircle : Circle -> Svg Msg
viewCircle circle =
  Svg.circle [
    cx (toString circle.x), cy (toString circle.y), r (toString circle.r),
    style ("fill:" ++ (color circle))
  ] []

onClick : Svg.Attribute Msg
onClick =
  on "click" (Json.map AddCircle getClickPos)

getClickPos : Json.Decoder (Int,Int)
getClickPos =
  Json.object2 (,)
    (Json.at ["offsetX"] Json.int)
    (Json.at ["offsetY"] Json.int)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    AddCircle (x, y) -> (addCircle (x, y) model, play (freq model.nextRand))
    Tick t -> (tick model, Cmd.none)
    NewRand i -> Debug.log "newRand" ({ model | nextRand = i }, Cmd.none)

tick : Model -> Model
tick model =
  let
    updated = List.map (\c -> { c| r = c.r - 0.2 }) model.circles
    remaining = List.filter (\c -> c.r > 0) updated
  in
    { model | circles = remaining }

freq: Int -> Float
freq seed =
  toFloat(seed) * 100.0


addCircle : (Int, Int) -> Model -> Model
addCircle (x, y) model =
  { model | circles = (Circle x y 80 model.nextRand) :: model.circles }

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every (Time.second / 60) Tick
