import Html exposing (Html)
import Html.App as App
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json

type alias Circle = { x : Int, y : Int, r : Int }
type alias Model = { circles : List Circle }

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type Msg = AddCircle (Int, Int)

init : (Model, Cmd Msg)
init =
  ({ circles = [] }, Cmd.none)

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
    style "fill:#ca0;"
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
    AddCircle (x, y) -> (addCircle (x, y) model, Cmd.none)

addCircle : (Int, Int) -> Model -> Model
addCircle (x, y) model =
  { model | circles = (Circle x y 80) :: model.circles }

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
