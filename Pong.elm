-- http://elm-lang.org/blog/making-pong

import Time exposing ( Time, fps, inSeconds )
import Graphics.Collage exposing ( Shape, Form, collage, move, toForm, rect, oval, filled )
import Graphics.Element exposing ( Element, container, spacer, middle,
  leftAligned )
import Color exposing ( white, rgb )
import Keyboard
import Text exposing ( fromString, monospace )
import Window

-- This game has two primary inputs: the passage of time and key presses
type alias Input =
  { space : Bool
  , paddle1: Int
  , paddle2: Int
  , delta: Time }

{--
To keep track of the passage of time, we define delta using the fps
function. The fps takes a target frames-per-second and gives a sequence of time
deltas that gets as close to the desired FPS as possible. If the browser can not
keep up, the time deltas will slow down gracefully.
--}

delta : Signal Time
delta =
  Signal.map inSeconds (fps 35)

{--
Notice that we sample on time deltas so that keyboard events do not cause extra
updates. We want 35 frames per second, not 35 plus the number of key presses.
--}
input : Signal Input
input =
  Signal.sampleOn delta <|
    Signal.map4 Input
      Keyboard.space
      (Signal.map .y Keyboard.wasd)
      (Signal.map .y Keyboard.arrows)
      delta

-- ## Model

{--
The most basic thing we need to model is the “pong court”. This just comes down
to the dimensions of the court to know when the ball should bounce and where the
paddles should stop.
--}

(gameWidth,gameHeight) = (600,400)
(halfWidth,halfHeight) = (300,200)

type alias Object a =
  { a |
      x: Float,
      y: Float,
      vx: Float,
      vy: Float
  }

type alias Ball =
  Object {}

type alias Player =
  Object { score : Int }

{--
We also want to be able to pause the game between volleys so the user can take a
break. We do this with a union type
--}
type State = Play | Pause

{--
We now have a way to model balls, players, and the game state, so we just need
to put it together. We define a Game that includes all of these things and then
create a default game state.
--}
type alias Game =
  { state : State
  , ball: Ball
  , player1: Player
  , player2: Player
  }

player : Float -> Player
player x =
  { x=x, y=0, vx=0, vy=0, score=0 }

defaultGame : Game
defaultGame =
  { state = Pause
  , ball = { x=0, y=0, vx=200, vy=200 }
  , player1 = player (20-halfWidth)
  , player2 = player (halfWidth-20)
  }

-- UPDATE
-- ======

{--
 In this section we will define a step function that steps from Game to Game,
 moving the game forward as new inputs come in.
--}

-- are n and m near each other?
-- specifically are they within c of each other?
near: Float -> Float -> Float -> Bool
near n c m =
  m >= n-c && m <= n+c

-- is the ball within a paddle?
within: Ball -> Player -> Bool
within ball player =
  near player.x 8 ball.x
  && near player.y 20 ball.y

-- change the direction of a velocity based on collisions
stepV: Float -> Bool -> Bool -> Float
stepV v lowerCollision upperCollision =
  if lowerCollision then
    abs v
  else if upperCollision then
    -(abs v)
  else
    v

-- stepObj changes an objects position based on its velocity
stepObj: Time -> Object a -> Object a
stepObj t ({x,y,vx,vy} as obj) =
  { obj |
    x = x + vx * t,
    y = y + vy * t
  }

-- move a ball forward, detecting collisions with either paddle
stepBall: Time -> Ball -> Player -> Player -> Ball
stepBall t ({x,y,vx,vy} as ball) player1 player2 =
  if not (ball.x |> near 0 halfWidth)
    then { ball | x = 0, y = 0 }
    else
      stepObj t
        { ball |
          vx = stepV vx (ball `within` player1) (ball `within` player2),
          vy = stepV vy (y < 7 - halfHeight) (y > halfHeight - 7)
        }

-- step a player forward, making sure it does not fly off the court
stepPlyr: Time -> Int -> Int -> Player -> Player
stepPlyr t dir points player =
  let player' = stepObj t { player | vy = toFloat dir * 200 }
      y' = clamp (22 - halfHeight) (halfHeight - 22) player'.y
      score' = player.score + points
  in
      { player' | y = y', score = score' }

{--
Now that we have the stepBall and stepPlyr helper functions, we can define a
step function for the entire game.  Here we are stepping our game forward based
on inputs from the world.
--}

stepGame: Input -> Game -> Game
stepGame input game =
  let
    {space, paddle1, paddle2, delta} = input
    {state, ball, player1, player2 } = game

    score1 =
      if ball.x > halfWidth then 1 else 0
    score2 =
      if ball.x < -halfWidth then 1 else 0

    state' =
      if space then
        Play
      else if score1 /= score2 then
        Pause
      else
        state

{--      if | space -> Play
         | score1 /= score2 -> Pause
         | otherwise -> State
--}

    ball' =
      if state == Pause
        then ball
        else stepBall delta ball player1 player2

    player1' = stepPlyr delta paddle1 score1 player1
    player2' = stepPlyr delta paddle2 score2 player2
  in
    { game |
      state = state',
      ball = ball',
      player1 = player1',
      player2 = player2'
    }

{--
Finally we put together the inputs, the default game, and the step function to
define gameState.
--}

gameState : Signal Game
gameState =
  Signal.foldp stepGame defaultGame input


-- VIEW
-- ====

-- helpers
pongGreen = rgb 60 100 60
textGreen = rgb 160 200 160
txt f = leftAligned << f << monospace << Text.color textGreen << fromString
msg = "SPACE to start, WS and &uarr;&darr; to move"

-- shared function for rendering objects
displayObj: Object a -> Shape -> Form
displayObj obj shape =
  move (obj.x, obj.y) (filled white shape)

-- display game state
display: (Int, Int) -> Game -> Element
display (w, h) game =
  let
    {state, ball, player1, player2} = game
    scores : Element
    scores =
      toString player1.score ++ "  " ++ toString player2.score
        |> txt (Text.height 50)
  in
    container w h middle <|
    collage gameWidth gameHeight
      [ filled pongGreen (rect gameWidth gameHeight)
      , displayObj ball (oval 15 15)
      , displayObj player1 (rect 10 40)
      , displayObj player2 (rect 10 40)
      , toForm scores
        |> move (0, gameHeight / 2 - 40)
      , toForm (if state == Play then spacer 1 1 else txt identity msg)
        |> move (0, 40 - gameHeight / 2)
      ]

main =
  Signal.map2 display Window.dimensions gameState
