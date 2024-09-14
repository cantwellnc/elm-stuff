module Init exposing (..)

import Browser
import Debug exposing (toString)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)



-- Elm follows the MVC architecture:
-- Model — the state of your application
-- View — a way to turn your state into HTML
-- Update — a way to update your state based on messages
-- Elm starts by rendering the initial value on screen. From there you enter into this loop:
-- Wait for user input.
-- Send a message to update
-- Produce a new Model
-- Call view to get new HTML
-- Show the new HTML on screen
-- Repeat!


getOut string =
    "aaaas"



-- Main
-- main is special! it descibes what actually gets shown on screen.


main =
    Browser.sandbox { init = init, update = update, view = view }



-- Model


type alias Model =
    Int


init : Model
init =
    0



-- Update


type Msg
    = Increment
    | Decrement
    | Reset
    | IncrementBy10


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1

        IncrementBy10 ->
            model + 10

        Reset ->
            init



-- View


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , button [ onClick Increment ] [ text "+" ]
        , button [ onClick IncrementBy10 ] [ text "+10" ]
        , button [ onClick Reset ] [ text "RESET!" ]
        , div [] [ text (toString model) ]
        ]
