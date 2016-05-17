# Testing

There are five different functions to create assertions:

```
assert : Bool -> Assertion
assertEqual : a -> a -> Assertion
assertNotEqual : a -> a -> Assertion
lazyAssert : (() -> Bool) -> Assertion
assertionList : List a -> List a -> List Assertion
```

```bash
elm-package install -y elm-lang/core
elm-package install -y elm-community/elm-test
```

```elm
import ElmTest exposing (..)
import String


tests : Test
tests =
    suite "A Test Suite"
        [
            test "Addition" (assertEqual (3 + 7) 10),
            test "String.left" (assertEqual "a" (String.left 1 "abcdefg")),
            test "This test should pass" (assert True)
        ]

main =
    runSuite tests
```

```bash
elm-make tests/Tests.elm --output testRunner.js && node testRunner.js
```
