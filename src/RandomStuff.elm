module RandomStuff exposing (..)

import Random


type Symbol
    = Cherry
    | Seven
    | Bar
    | Grapes


symbol : Random.Generator Symbol
symbol =
    Random.uniform Cherry [ Seven, Bar, Grapes ]


type alias Spin =
    { one : Symbol
    , two : Symbol
    , three : Symbol
    }


spin : Random.Generator Spin
spin =
    Random.map3 Spin symbol symbol symbol
