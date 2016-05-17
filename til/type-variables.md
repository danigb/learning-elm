# Type variables

http://guide.elm-lang.org/types/union_types.html (Generic Data Structures)

```
> type List a = Empty | Node a (List a)
```

The fancy part comes in the Node constructor. Instead of pinning the data to Int and
 IntList, we say that it can hold a and List a. Basically, you can add a value
 as long as it is the same type of value as everything else in the list.

 http://package.elm-lang.org/packages/elm-lang/core/latest/List
 
