module Music exposing (..)
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (href)
import Html.App as App

import Time
import Task
import Random

import Ports exposing (play, Event)


phrase : Float -> List Int -> List Event
phrase dur notes =
  List.indexedMap (\i n -> Event (dur * toFloat i) n) notes

chromatic : List Int
chromatic =
  List.append [60..72] (List.reverse [60..71])



randomList n =
  Random.list n (Random.int 40 90)


main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type alias Model = { ready : Bool, seed : Random.Seed, inst : String }

type Msg =
  NewSeed Random.Seed
  | Loaded String
  | ChromaticExample
  | RandomExample
  | RandomList (List Int)


getCurrentSecs : Cmd Msg
getCurrentSecs =
  let
    timeToSeed t = Random.initialSeed (floor (Time.inSeconds t))
  in
    Task.perform (\_ -> NewSeed (timeToSeed 0)) (\t -> NewSeed (timeToSeed t)) Time.now

init : (Model, Cmd Msg)
init = ({ ready = False, inst = "", seed = Random.initialSeed 0 }, getCurrentSecs)

view : Model -> Html Msg
view model =
  let
    viewHead = Html.h1 [] [text "Elm music1 example"]
    viewLoading = div [] [text "Loading piano..."]
    viewLoaded name = div [] [
      Html.h2 [] [text ("Instrument: " ++ name)],
      Html.a [href "#", onClick ChromaticExample] [text "chromatic"], Html.br [] [],
      Html.a [href "#", onClick RandomExample] [text "random"]
    ]
  in
    Html.div [] [viewHead, if model.ready then viewLoaded model.inst else viewLoading]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewSeed s -> Debug.log "seed" ({ model | seed = s }, Cmd.none)
    Loaded name -> ({ model | ready = True, inst = name }, play "a3")
    ChromaticExample -> (model, Ports.schedule (phrase 0.2 chromatic))
    RandomExample -> (model, Random.generate RandomList (randomList 10))
    RandomList list -> (model, Ports.schedule (phrase 0.5 list))


subscriptions : Model -> Sub Msg
subscriptions model =
  Ports.loaded Loaded
