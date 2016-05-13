import Html exposing (Html)
import Html.App exposing (program)
import Svg exposing (circle, line, svg)
import Svg.Attributes exposing (..)
import Time exposing (Time, second)
import Date


main =
  program { init = init, view = view, update = update, subscriptions = subs }


-- MODEL

type alias Model = Time


-- VIEW

hand color angle =
  let
    handX = toString (50 + 40 * cos angle)
    handY = toString (50 + 40 * sin angle)
  in
    line [ x1 "50", y1 "50", x2 handX, y2 handY, stroke color] []

-- https://en.wikipedia.org/wiki/Clock_angle_problem
view : Model -> Html Msg
view model =
  let
    date = Date.fromTime model
    sAng = degrees (toFloat (6 * Date.second date))
    mAng = degrees (6 * Time.inMinutes model)
    hAng = degrees (6 * Time.inMinutes model)
    h = Debug.log "hours" (Time.inHours model)
  in
    svg [ viewBox "0 0 100 100", width "300px" ]
      [ circle [ cx "50", cy "50", r "45", fill "#EFEFEF" ] []
      , hand "red" sAng
      , hand "orange" mAng
      , hand "blue" hAng
      ]


-- UPDATE

type Msg
  = Tick Time


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      (newTime, Cmd.none)

init : (Model, Cmd Msg)
init =
  (0, Cmd.none)


subs : Model -> Sub Msg
subs model =
  Time.every second Tick
