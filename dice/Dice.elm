import Html exposing ( Html, text, button, h1, div )
import Html.App as App
import Html.Events exposing ( onClick )
import Random



main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { face : Int
  }


init : (Model, Cmd Msg)
init =
  (Model 1, Cmd.none)

-- UPDATE

type Msg
  = Roll
  | NewFace Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      (model, Random.generate NewFace (Random.int 1 6))

    NewFace newFace ->
      (Model newFace, Cmd.none)



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text (toString model.face) ]
    , button [ onClick Roll ] [ text "Roll" ]
    ]
