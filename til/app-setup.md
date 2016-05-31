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
