port module Ports exposing (..)

port load : String -> Cmd msg

port loaded : (String -> msg) -> Sub msg

port play : String -> Cmd msg

type alias Event = { time : Float, note : Int }

port schedule : List (Event) -> Cmd msg
