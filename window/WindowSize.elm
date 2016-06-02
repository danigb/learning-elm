import Html exposing (Html)
import Html.App as App
import Window
import Task


main =
  App.program { init = init, view = view, update = update, subscriptions = subscriptions }

type alias Model = { width : Int, height : Int }
type Msg =
  Error
  | WindowSize Window.Size

init =
  let requestSize =
    Task.perform (always Error) WindowSize Window.size
  in
  ((Model 0 0), requestSize)

view m =
  let
    size = "width: " ++ toString(m.width) ++ " height: " ++ toString(m.height)
  in
    Html.div [] [Html.text size]

update msg model =
  case msg of
    WindowSize size -> (Model size.width size.height, Cmd.none)
    Error -> (model, Cmd.none)

subscriptions model =
  Window.resizes WindowSize
