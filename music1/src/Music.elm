module Music exposing (..)
import Html exposing (Html, div, text)
import Html.App as App
import Ports

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type alias Model = { ready : Bool, inst : String }

type Msg =
  Loaded String

init : (Model, Cmd Msg)
init = ({ ready = False, inst = "" }, Cmd.none)

view : Model -> Html Msg
view model =
  let
    viewLoading = div [] [text "Loading piano..."]
    viewLoaded name = div [] [text name]
  in
    if model.ready then viewLoaded model.inst else viewLoading


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Loaded name -> ({ ready = True, inst = name }, Ports.play "a3")


subscriptions : Model -> Sub Msg
subscriptions model =
  Ports.loaded Loaded
