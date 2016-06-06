port module Ports exposing (..)

port click: (Float, String) -> Cmd msg

port getAudioTime: Float -> Cmd msg

port currentAudioTime: (Float -> msg) -> Sub msg
