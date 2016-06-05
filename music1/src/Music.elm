module Music exposing (..)
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (href)
import Html.App as App

import Time
import Task
import Random

import Ports exposing (play, Event)


sequence : Float -> List Int -> List Event
sequence dur notes =
  List.indexedMap (\i n -> Event (dur * toFloat i) n) notes

chromatic : List Int
chromatic =
  List.append [60..72] (List.reverse [60..71])



randomNoteList n =
  Random.list n (Random.int 40 90)

-- Twelve Tone Example
randomOctaves size =
  Random.list size (Random.map (\n -> n * 12) (Random.int 0 1))

repeat : Int -> List a -> List a
repeat times list =
  List.concat (List.map (\a -> list) [1..times])


twelveTone : Int -> List Int -> List Int
twelveTone key octs =
  let
    inKey = List.map ((+) key) [0, 1, 6, 7, 10, 11, 5, 4, 3, 9, 2, 8]
  in
    List.map2 (+) octs (repeat 4 inKey)


main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type alias Model = { ready : Bool, seed : Random.Seed, inst : String }

type Msg =
  NewSeed Random.Seed
  | Loaded String
  | ChromaticExample
  | RandomExample
  | RandomList (List Int)
  | TwelveToneExample
  | TwelveToneOcts (List Int)


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
      Html.a [href "#", onClick RandomExample] [text "random"], Html.br [] [],
      Html.a [href "#", onClick TwelveToneExample] [text "twelve tone"], Html.br [] []
    ]
  in
    Html.div [] [viewHead, if model.ready then viewLoaded model.inst else viewLoading]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewSeed s -> Debug.log "seed" ({ model | seed = s }, Cmd.none)
    Loaded name -> ({ model | ready = True, inst = name }, play "a3")
    ChromaticExample -> (model, Ports.schedule (sequence 0.2 chromatic))
    RandomExample -> (model, Random.generate RandomList (randomNoteList 10))
    RandomList list -> (model, Ports.schedule (sequence 0.5 list))
    TwelveToneExample -> (model, Random.generate TwelveToneOcts (randomOctaves (4 * 11)))
    TwelveToneOcts octs -> (model, Ports.schedule (sequence 0.5 (twelveTone 60 octs)))


subscriptions : Model -> Sub Msg
subscriptions model =
  Ports.loaded Loaded
