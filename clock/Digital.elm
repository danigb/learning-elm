import Html exposing (Html, div, text)
import Html.App exposing (program)
import Time exposing (Time, second)
import Date

main =
  program { init = init, view = view, update = update, subscriptions = subs }

-- MODEL

type alias Model = Time

-- VIEW

view model =
  let
    date = Date.fromTime model
    h = Date.hour date
    m = Date.minute date
    secs = Date.second date
  in
    div []
      [ div [] [ text (toString h)]
      , div [] [ text (toString m)]
      , div [] [ text (toString secs)]
      ]

-- UPDATE

type Msg = Tick Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      (newTime, Cmd.none)

init : (Model, Cmd Msg)
init = (0, Cmd.none)

subs : Model -> Sub Msg
subs model =
  Time.every second Tick
