module CommandsAndSubscriptions exposing (..)

import Browser
import Html exposing (Html, pre, text)
import Http



{-
   Browser.sandbox
    does not allow communication with the outside world
    you're basically just communicating with the runtime, which
    does the work of figuring out DOM changes, sending messages to
    your elm code on user input, etc.
   Browser.element
    this will allow us to interact with the world
    in addition to producing Html, our programs can sending
    Cmd (commands) and Sub (subscriptions) requests to the runtime
    to perform side effects (or subscribe to some effectful thing, ex:
    the current time).
-}
--Main


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- Model


type Model
    = Failure
    | Loading
    | Success String


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Http.get
        { url = "https://elm-lang.org/assets/public-opinion.txt"
        , expect = Http.expectString GotText
        }
    )



-- Update


type Msg
    = GotText (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotText result ->
            case result of
                Ok fullText ->
                    ( Success fullText, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- View


view : Model -> Html Msg
view model =
    case model of
        Failure ->
            text "I was unable to load the book :("

        Loading ->
            text "Loading..."

        Success fullText ->
            pre [] [ text fullText ]
