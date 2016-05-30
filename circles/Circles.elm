import Html exposing (Html)
import Html.App as App
import Svg exposing (Svg, rect)
import Svg.Attributes exposing (..)

type alias Model = { }

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type Msg = AddCircle (Int, Int)

init : (Model, Cmd Msg)
init =
  (Model, Cmd.none)

view : Model -> Html Msg
view model =
  Svg.svg [id "circles-app"] [
    rect [x "0", y "0", width "100%", height "100%"] []
  ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
