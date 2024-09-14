module Types exposing (..)

-- when you create a type alias for a record, it also generates
-- a record constructor that can be used to create instances of that type
-- ex:


type alias User =
    { fname : String, lname : String }



-- Interesting, let bindings do not work in global scope?
-- they seem to only work in the context of a function
-- This works:


intro =
    let
        user =
            User "a" "b"
    in
    user.fname ++ "D"



-- This breaks the compiler:
-- let
--     user =
--         User "a" "b"
--     in
--     user.fname ++ "D"
