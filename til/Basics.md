# Basics

http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Basics


## Equality

__a -> a -> Bool__

`==`, `/=`

## Comparison

__comparable -> comparable -> Bool__

`>`, `<`, `>=`, `<=`,

__comparable -> comparable -> comparable__

`max`, `min`

__comparable -> comparable -> Order__

`compare`

`type Order = LT | EQ | GT`


## Booleans

`not` (Bool -> Bool)
`&&`, `||`, `xor` (Bool -> Bool -> Bool)

## Mathematics

__number -> number__

`negate` (negative), `abs` (absolute)

__number -> number -> number__

`+`, `-`, `*`, `^`

__number -> number -> number -> number__

`clamp` Clamps a number within a given range

```
clamp 100 200 x =>
  if x < 100 then 100
  if x > 200 then 200
  else x
```

__Int -> Int -> Int__

`//`, `rem` (remainder), `%`

__Float__

`e`

__Float -> Float__

`sqrt`

__Float -> Float -> Float__

`/`, `logBase` (the logarithm of a number with a given base, base first, obviously ;-)
