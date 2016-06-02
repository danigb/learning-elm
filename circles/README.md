# Circles

A simplified version of: https://github.com/irh/circles

## 1. Basic structure

```elm
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
```

## 2. Embed Elm in HTML

http://guide.elm-lang.org/interop/html.html

```html
<html>
  <head>
    <title>Circles</title>
    <link rel="stylesheet" type="text/css" href="assets/circles.css" media="screen" />
  </head>
  <body></body>
  <script src="assets/circles.js"></script>
  <script>
    Elm.Main.fullscreen()
  </script>
</html>
```

## 3. Add listeners

```elm
type Msg = AddCircle (Int, Int)

onClick : Svg.Attribute Msg
onClick =
  on "click" (Json.map AddCircle getClickPos)

getClickPos : Json.Decoder (Int,Int)
getClickPos =
  Json.object2 (,)
    (Json.at ["offsetX"] Json.int)
    (Json.at ["offsetY"] Json.int)

view =
  Svg.rect [x "0", y "0", width "100%", height "100%", onClick ] []
```

## 4. Update model

```elm
type alias Circle = { x : Int, y : Int, r : Int }
type alias Model = { circles : List Circle }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    AddCircle (x, y) -> (addCircle (x, y) model, Cmd.none)

addCircle : (Int, Int) -> Model -> Model
addCircle (x, y) model =
  { model | circles = (Circle x y 80) :: model.circles }
```

## 5. Draw circles

```elm
view : Model -> Html Msg
view model =
  let
    bg = Svg.rect [x "0", y "0", width "100%", height "100%", onClick ] []
    circles = List.map viewCircle model.circles
  in
    Svg.svg [id "circles-app"] (bg :: circles)
```

## 6. Generate random

```elm
random : Cmd Msg
random =
  Random.generate NewRand (Random.int 0 11)

update msg model =
  case msg of
    AddCircle (x, y) -> (addCircle x y model, random)
```

## 7. Talk to JS

```elm
port module Ports exposing (..)

{- Play with given frequency -}
port play : Float -> Cmd msg
```

```elm
update msg model =
  case msg of
    AddCircle (x, y) -> (addCircle x y model, Cmd.batch [random, (play 440)])
```
