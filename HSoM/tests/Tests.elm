import ElmTest exposing (..)
import Music exposing (..)
import String


tests : Test
tests =
    suite "A Test Suite"
        [
            test "Addition" (assertEqual (3 + 7) 10),
            test "String.left" (assertEqual "a" (String.left 1 "abcdefg")),
            test "This test should pass" (assert True)
        ]

music : Test
music =
  suite "Music"
    [
      test "Rest" (assertEqual (Rest 3) (Rest 3) ),
      test "Note" (assertEqual (Note 3 (C, 4)) (Note 3 (C, 4))),
      test "Prim Rest" (assertEqual (Prim (Rest 3))
        (Prim (Rest 3))),
      test "Prim Note" (assertEqual (Prim (Note 4 (C, 5)))
        (Prim (Note 4 (C, 5)))),
      test "note" (assertEqual (note 3 C) (Prim (Note 3 C))),
      test "rest" (assertEqual (rest 1) (Prim (Rest 1))),
      test "tempo" (assertEqual (tempo 4 (note 3 C))
        (Modify (Tempo 4) (Prim (Note 3 C)))),
      test "absPitch" (assertEqual 48 (absPitch (C, 4)))
    ]

main =
    runSuite music
