module Knob exposing (..)
import Html exposing (Html)
import Html.App as App
import Html.Attributes as Attr
import Svg
import Svg.Attributes exposing (cx, cy, r, d, class, width, height)
import VirtualDom exposing(on)
import Mouse exposing (Position)
import Json.Decode as Json

-- SVH PATH HELPERS
toS o = " " ++ (toString o)
pM x y = "M " ++ (toString x) ++ " " ++ (toString y)
pA rx ry rot large sweep x y =
  "A" ++ toS rx ++ toS ry ++ toS rot ++ toS large ++ toS sweep ++ toS x ++ toS y


type alias Drag = { start: Position, current: Position }
type alias Model = { min: Float, max: Float, value: Float, drag: Maybe Drag }
type Msg = DragStart Position | DragAt Position | DragEnd Position

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

init : (Model, Cmd Msg)
init = (Model 0 100 50 Nothing, Cmd.none)

dragValue : Maybe Drag -> Int
dragValue drag =
  case drag of
    Nothing -> 0
    Just pos -> pos.start.y - pos.current.y

value : Model -> Float
value model =
  let
    step = (model.max - model.min) / 100
    offsetVal = toFloat (dragValue model.drag) * step
  in
    max model.min (min model.max (model.value + offsetVal))


view : Model -> Html Msg
view model =
  let
    val = value model
    normValue = (val - model.min) / (model.max - model.min)
    target = normValue * pi * 1.5
    c = 23.5 -- center
    ar = 19 -- arc Radius
    offset = pi * 0.75
    x1 = c + ar * cos(offset)
    y1 = c + ar * sin(offset)
    x2 = c + ar * cos(offset + target)
    y2 = c + ar * sin(offset + target)
    flag = if target < pi then 0 else 1
    m = (pM x1 y1) ++ " " ++ (pA ar ar 0 flag 1 x2 y2)
    sC = toString c
  in
    Html.div [Attr.class "knob"] [
      Html.div [Attr.class "label"] [Html.text "Name"],
      Svg.svg [class "knob", onMouseDown, width "48", height "48"] [
        Svg.circle [cx sC, cy sC, r "23", class "outer"] [],
        Svg.path [class "gauge", d m] [],
        Svg.circle [cx sC, cy sC, r "16", class "inner"] []
      ],
      Html.div [Attr.class "label"] [Html.text (toString val)]
    ]

onMouseDown : Svg.Attribute Msg
onMouseDown =
  on "mousedown" (Json.map DragStart Mouse.position)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    DragStart pos -> ({ model | drag = Just (Drag pos pos)}, Cmd.none)
    DragAt pos -> ({ model | drag = Maybe.map (\{start} -> Drag start pos) model.drag }, Cmd.none)
    DragEnd pos -> ({model | value = value model, drag = Nothing }, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.drag of
    Nothing -> Sub.none
    Just _ -> Sub.batch [ Mouse.moves DragAt, Mouse.ups DragEnd ]
