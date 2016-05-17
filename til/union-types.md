# Union types

## Constructors

```elm
> type User = Named String
> Named
<function> : String -> Repl.User
> Named "dani"
Named "dani" : Repl.User
```

Create the type User with constructors named Anonymous and Named. If you want to create a User you must use one of these two __constructors__.

```elm
> type User = Anonymous | Named String
> Anonymous
Anonymous : Repl.User
> Named "dani"
Named "dani" : Repl.User
> Named
<function> : String -> Repl.User
```

```elm
> type Widget = Logs LogsInfo | TimePlot TimeInfo | ScatterPlot ScatterInfo
```

So we created a Widget type that can only be created with these constructor functions. You can think of these constructors as tagging the data so we can tell it apart at runtime.

## Takeaways:

- Solve each subproblem first.
- Use union types to put together all the solutions.
- Creating a union type generates a bunch of constructors.
- These constuctors tag data so that we can differentiate it at runtime.
- A `case` expression lets us tear data apart based on these tags.

The same strategies can be used if you are making a game and have a bunch of different bad guys. Goombas should update one way, but Koopa Troopas do something totally different. Solve each problem independently, and then use a union type to put them all together.
