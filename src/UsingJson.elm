module UsingJson exposing (..)

import Browser
import CommandsAndSubscriptions exposing (Msg, subscriptions)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, int, map4, string)



-- Main


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
    | Success Quote


type alias Quote =
    { quote : String
    , source : String
    , author : String
    , year : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getRandomQuote )



-- Update


type Msg
    = MorePlease
    | GotQuote (Result Http.Error Quote)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MorePlease ->
            ( Loading, getRandomQuote )

        GotQuote result ->
            case result of
                Ok quote ->
                    ( Success quote, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- View


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Random Quotes" ]
        , viewQuote model
        ]


viewQuote : Model -> Html Msg
viewQuote model =
    case model of
        Failure ->
            div []
                [ text "I could not load the quote :( "
                , button [ onClick MorePlease ] [ text "Try Again!" ]
                ]

        Loading ->
            text "Loading..."

        Success quote ->
            div []
                [ button [ onClick MorePlease, style "display" "block" ] [ text "More Please!" ]
                , blockquote [] [ text quote.quote ]
                , p [ style "text-align" "right" ]
                    [ text "— "
                    , cite [] [ text quote.source ]
                    , text (" by " ++ quote.author ++ " (" ++ String.fromInt quote.year ++ ")")
                    ]
                ]



-- HTTP


getRandomQuote : Cmd Msg
getRandomQuote =
    Http.get
        { url = "https://elm-lang.org/api/random-quotes"
        , expect = Http.expectJson GotQuote quoteDecoder
        }


quoteDecoder : Decoder Quote
quoteDecoder =
    -- note: there is no way to catch typos in JSON decoders
    -- using the compiler
    map4 Quote
        (field "quote" string)
        (field "source" string)
        (field "author" string)
        (field "year" int)



{-


   to handle nested data, you can NEST decoders easily:
    {
     "quote": "December used to be a month but it is now a year",
     "source": "Letters from a Stoic",
     "author":
     {
       "name": "Seneca",
       "age": 68,
       "origin": "Cordoba"
     },
     "year": 54
    }
      import Json.Decode exposing (Decoder, map2, map4, field, int, string)

      type alias Quote =
        { quote : String
        , source : String
        , author : Person
        , year : Int
        }

      quoteDecoder : Decoder Quote
      quoteDecoder =
        map4 Quote
          (field "quote" string)
          (field "source" string)
          (field "author" personDecoder)
          (field "year" int)

      type alias Person =
        { name : String
        , age : Int
        }

      personDecoder : Decoder Person
      personDecoder =
        map2 Person
          (field "name" string)
          (field "age" int)
-}
