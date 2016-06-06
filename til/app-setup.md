# Minimum app setup

```elm
import Html exposing (Html)
import Html.App as App

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

init = ({}, Cmd.none)

view model =
  Html.div [] [Html.text "Hola"]

update msg model =
  (model, Cmd.none)

subscriptions model =
  Sub.none
```

With model:

```elm
import Html exposing (Html)
import Html.App as App

type alias Model = {}
type Msg = None

main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

init : (Model, Cmd Msg)
init = ({}, Cmd.none)

view : Model -> Html Msg
view model =
  Html.div [] [Html.text "Hola"]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

```
