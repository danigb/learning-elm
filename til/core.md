# Core

## Functions

```elm
> isNegative n = n < 0
<function> : number -> Bool
> isNegative 3
False : Bool
> isNegative -1
True : Bool
> isNegative (-3 * -4)
False : Bool
```

Notice that function application looks different than in languages like JavaScript and Python and Java. Instead of wrapping all arguments in parentheses and separating them with commas, __we use spaces to apply the function__.

Using a backslash in the REPL lets us split things on to multiple lines. We use this in the definition of over9000 above. Furthermore, it is best practice to always bring the body of a function down a line. It makes things a lot more uniform and easy to read, so you want to do this with all the functions and values you define in normal code.

## Lists

```elm
> double n = n * 2
<function> : number -> number
> List.map double [23, 43,5,454]
[46,86,10,908] : List number
```

## Records

```elm
> point = { x = 3, y = 2 }
{ x = 3, y = 2 } : { x : number, y : number' }
```

__Record access__

So we can create records using curly braces and access fields using a dot. Elm also has a version of record access that works like a function. By starting the variable with a dot, you are saying please access the field with the following name. This means that .name is a function that gets the name field of the record.

```elm
> c4 = { letter = "C", octave = 4 }
{ letter = "C", octave = 4 } : { letter : String, octave : number }
> .letter c4
"C" : String
> List.map .octave [c4, c4]
[4,4] : List number
```

__Pattern matching__

```elm
> isC {letter} = letter == "C"
<function> : { a | letter : String } -> Bool
> isC c2
True : Bool
```

__Update records__

```elm
> { c2 | letter ="Dbb"}
{ letter = "Dbb", octave = 4 } : { octave : number, letter : String }
> c2
{ letter = "C", octave = 4 } : { letter : String, octave : number }
> c3 = { c2 | octave = 3 }
{ letter = "C", octave = 3 } : { letter : String, octave : number }
> cb2 = { c2 | alteration = -1 }
-- TYPE MISMATCH
```

```elm
```
