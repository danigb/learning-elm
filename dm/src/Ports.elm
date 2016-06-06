port module Ports exposing (..)

port play : (String, Float) -> Cmd msg

port getAudioTime: Float -> Cmd msg

port currentTime: (Float -> msg) -> Sub msg
