import Time exposing ( second )
import Mouse exposing ( position )
import Html

main =
  Signal.map clock (Time.every second)

clock t =
  Html.text (toString t)
