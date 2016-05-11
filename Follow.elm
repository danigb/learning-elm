import Window
import Mouse
import Graphics.Element exposing ( Element, show )
import Graphics.Collage exposing ( collage, move, oval, filled )
import Color

main =
  Signal.map2 view Window.dimensions Mouse.position

view : (Int, Int) -> (Int, Int) -> Element
view (w, h) (x, y) =
  let
    mw = w // 2
    mh = h // 2
  in
    collage w h [
      move (toFloat (x - mw), toFloat (mh - y)) (filled Color.red (oval 40 40))
    ]
