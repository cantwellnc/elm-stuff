module Clock exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (style)
import Json.Decode exposing (int)
import String exposing (toInt)
import Svg
import Svg.Attributes as SvgAttrs
import Task
import Time



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    , secondsAngle : Float
    , minutesAngle : Float
    , hoursAngle : Float
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0) (pi / 2) (pi / 2) (pi / 2)
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = SecondTick Time.Posix
    | MinuteTick Time.Posix
    | HourTick Time.Posix
    | AdjustTimeZone Time.Zone



-- jesus christ why is it so hard to figure out the correct starting positions for the second and minute hands???
-- the hour hand goes in the right place, but it is totally not clear to me WHY only that one seems to work...


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SecondTick newTime ->
            ( { model
                | time = newTime
                , secondsAngle = model.secondsAngle + (2 * pi / 60)
              }
            , Cmd.none
            )

        MinuteTick newTime ->
            ( { model
                | time = newTime
                , minutesAngle = model.minutesAngle + (2 * pi / 60)
                , secondsAngle = model.secondsAngle + (2 * pi / 360)
              }
            , Cmd.none
            )

        HourTick newTime ->
            ( { model
                | time = newTime
                , hoursAngle = model.hoursAngle - (2 * pi / 12)
                , minutesAngle = model.minutesAngle - (2 * pi / 60)
                , secondsAngle = model.secondsAngle - (2 * pi / 360)
              }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model
                | zone = newZone
                , secondsAngle = model.secondsAngle - toFloat (Time.toSecond model.zone model.time) * 2 * pi / 60
                , minutesAngle = model.minutesAngle - toFloat (Time.toSecond model.zone model.time) * 2 * pi / 60
                , hoursAngle = model.hoursAngle - toFloat (modBy 12 (Time.toHour model.zone model.time)) * (2 * pi / 12)
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    -- batch : List (Sub msg) -> Sub msg
    Sub.batch
        [ Time.every 1000 SecondTick
        , Time.every
            (1000
                * 60
            )
            MinuteTick
        , Time.every
            (1000
                * 60
                * 60
            )
            HourTick
        ]



-- VIEW
--
-- NEED:
{-
   - a way of tracking hours, minutes, and seconds increments via subscriptions
   - a fn for turning posix time + time zone into (hours, seconds, minutes)
   - a way of moving hands a certain amount around the circle corresponding to their unit
   - a fn for turning (hours, seconds, minutes) into x,y coordinates (using cos x, sin x)
        - or better yet, into an angle?

-}
-- inCircle : Model -> Html Msg


presentClock model =
    let
        hour =
            String.fromInt (Time.toHour model.zone model.time)

        minute =
            String.fromInt (Time.toMinute model.zone model.time)

        second =
            String.fromInt (Time.toSecond model.zone model.time)
    in
    div
        []
        [ h1 [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
        , h1 [] [ text (Debug.toString model.time) ]
        , h1 [] [ text (Debug.toString model.secondsAngle) ]
        , h1 [] [ text (Debug.toString model.minutesAngle) ]
        , h1 [] [ text (Debug.toString model.hoursAngle) ]
        , Svg.svg
            [ SvgAttrs.height "1000"
            , SvgAttrs.width "1000"
            ]
            [ Svg.circle
                [ SvgAttrs.cx "500"
                , SvgAttrs.cy "500"
                , SvgAttrs.r "300"
                , SvgAttrs.opacity "1"
                , SvgAttrs.stroke "black"
                , SvgAttrs.strokeWidth "10"
                , SvgAttrs.fillOpacity "0"
                ]
                []
            , Svg.line
                -- Hour hand
                [ SvgAttrs.stroke "blue"
                , SvgAttrs.strokeWidth "10"
                , SvgAttrs.x1 "500"
                , SvgAttrs.y1 "500"
                , SvgAttrs.x2 (String.fromInt (floor (300 * cos model.hoursAngle + 500)))
                , SvgAttrs.y2 (String.fromInt (floor (300 * sin model.hoursAngle + 500)))
                ]
                []
            , Svg.line
                -- Minute hand
                [ SvgAttrs.stroke "green"
                , SvgAttrs.strokeWidth "10"
                , SvgAttrs.x1 "500"
                , SvgAttrs.y1 "500"
                , SvgAttrs.x2 (String.fromInt (floor (250 * cos model.minutesAngle + 500)))
                , SvgAttrs.y2 (String.fromInt (floor (250 * sin model.minutesAngle + 500)))
                ]
                []
            , Svg.line
                -- Seconds hand
                [ SvgAttrs.stroke "red"
                , SvgAttrs.strokeWidth "7"
                , SvgAttrs.x1 "500"
                , SvgAttrs.y1 "500"
                , SvgAttrs.x2 (String.fromInt (floor (200 * cos model.secondsAngle + 500)))
                , SvgAttrs.y2 (String.fromInt (floor (200 * sin model.secondsAngle + 500)))
                ]
                []
            ]
        ]


view : Model -> Html Msg
view model =
    presentClock model
