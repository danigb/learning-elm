import Html exposing ( Html, div, text )
import Html.Attributes exposing ( style )
import Html.App exposing ( program )
import Color exposing ( Color )

main =
  program { model = init, view = view, update = update, subscriptions = subs }

type alias Element =
  { color: Color, selected: Bool }

view =
  div []
    [
      div [ ] [ text 'Hola' ]
    ]

update
