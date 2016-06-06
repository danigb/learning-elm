module Sched exposing (Sched, init, isRunning, start, stop, tick, currentStep)
import Time exposing (Time)

type alias AudioTime = Float
type alias Sched = { tempo: Int, steps: Int, running: Bool, state: State }
type alias State = { startedAtAudio: AudioTime, startedAt: Time,
  lastTick: Time, lastStep: Int }

init: Int -> Int -> Sched
init tempo steps =
  Sched tempo steps False (State 0 0 0 -1)

isRunning : Sched -> Bool
isRunning sched = sched.running

currentStep : Sched -> Int
currentStep sched = sched.state.lastStep

start : Float -> Sched -> Sched
start when sched = Sched sched.tempo sched.steps True (State when 0 0 -1)
stop : Sched -> Sched
stop sched = Sched sched.tempo sched.steps False (State 0 0 0 -1)

tick : Time -> Sched -> Sched
tick time sched =
  if (isRunning sched)
    then { sched | state = (schedule time sched) }
    else sched

{- First tick call after start -}
schedule: Time -> Sched -> State
schedule time sched =
  let
    curState = sched.state
    secs = Time.inSeconds time
    startedAt = if curState.startedAt /= 0 then curState.startedAt else secs
    nextStep = floor (beat (sched.tempo * 4) startedAt secs) % sched.steps
    nextState = { curState | startedAt = startedAt, lastTick = secs, lastStep = nextStep }
  in
    nextState


beat : Int -> Float -> Float -> Float
beat tempo start current =
  (current - start) / (60 / toFloat tempo)
