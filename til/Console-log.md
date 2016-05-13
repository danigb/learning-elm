# Console.log

Since log is not a pure function, the only thing I came with is that:

```elm
update msg model =
  let
    d = Debug.log "update" (toString msg)
  in
    case msg of
      Tick newTime ->
        (newTime, Cmd.none)

```
