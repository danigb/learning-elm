import Html exposing (..)
import StartApp.Simple as StartApp
import Effects exposing ( Effects, Never )
import Html.Events exposing (..)
import Random

main =
  StartApp.start
    { model = init
    , view = view
    , update = update
    }

type alias Dice =
  { face : Int }

init : Dice
init =
  Dice 1

view : Signal.Address Action -> Dice -> Html
view address model =
  div []
    [ h1 [] [ text (toString model.face) ]
    , button [ onClick address Roll ] [ text "Roll" ]
    ]

type Action = Roll | NewFace Int

update : Action -> Dice -> (Dice, Effects Action)
update action model =
  case action of
    Roll ->
      (model, Effects.none)
    NewFace newFace ->
      (model newFace, Effects.none)
