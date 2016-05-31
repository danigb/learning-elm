module Matrix exposing (..)
import Array exposing (Array)
import Maybe exposing (withDefault)

type alias Row = (String, Array Int)
type alias Matrix = { names: List String, length: Int, rows: List Row }

initRow : Int -> Array Int
initRow length =
  Array.repeat length 0

init : List String -> Int -> Matrix
init names length =
  Matrix names length (List.map (\n -> (n, initRow length)) names)

getRow : String -> Matrix -> Row
getRow name matrix =
  let
    head = List.head (List.filter (\(n, r) -> n == name) matrix.rows)
  in
    case head of
      Just r -> r
      Nothing -> (name, Array.repeat 0 0)

getData : String -> Matrix -> List Int
getData name matrix =
  let
    (n, row) = getRow name matrix
  in
    Array.toList row

set : (Int -> Int) -> String -> Int -> Matrix -> Matrix
set fn name step matrix =
  let
    (name, row) = getRow name matrix
    val = withDefault 0 (Array.get step row)
    updated = Array.set step (fn val) row
    updatedRows = List.map (\(n, r) -> if n == name then (n, updated) else (n, r)) matrix.rows
  in
    Matrix matrix.names matrix.length updatedRows
