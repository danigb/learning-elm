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
  Svg.svg [class "view"] [
    rect [x "10px", y "10px", width "40px", height "40px"] []
  ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
