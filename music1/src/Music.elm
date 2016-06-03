module Music exposing (..)
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (href)
import Html.App as App
import Ports exposing (play, Event)


chromatic =
  List.indexedMap (\i n -> Event (0.2 * toFloat i) n) (List.append [60..72] (List.reverse [60..71]))



main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type alias Model = { ready : Bool, inst : String }

type Msg =
  Loaded String
  | Example1

init : (Model, Cmd Msg)
init = ({ ready = False, inst = "" }, Cmd.none)

view : Model -> Html Msg
view model =
  let
    viewHead = Html.h1 [] [text "Elm music1 example"]
    viewLoading = div [] [text "Loading piano..."]
    viewLoaded name = div [] [
      Html.h2 [] [text ("Instrument: " ++ name)],
      Html.a [href "#", onClick Example1] [text "chromatic"]
    ]
  in
    Html.div [] [viewHead, if model.ready then viewLoaded model.inst else viewLoading]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Example1 -> (model, Ports.schedule chromatic)
    Loaded name -> ({ ready = True, inst = name }, play "a3")


subscriptions : Model -> Sub Msg
subscriptions model =
  Ports.loaded Loaded
