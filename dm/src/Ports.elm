port module Ports exposing (..)

port play : (Float, String) -> Cmd msg

port getAudioTime: Float -> Cmd msg

port currentAudioTime: ((Float, Float) -> msg) -> Sub msg
