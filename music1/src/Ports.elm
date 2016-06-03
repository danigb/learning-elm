port module Ports exposing (..)

port play : String -> Cmd msg

port load : String -> Cmd msg

port loaded : (String -> msg) -> Sub msg
