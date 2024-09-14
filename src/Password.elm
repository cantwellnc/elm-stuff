module Password exposing (..)

import Browser
import Char exposing (isAlphaNum, isDigit, isLower, isUpper)
import Html exposing (Html, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reverse exposing (Model)


main =
    Browser.sandbox { init = init, update = update, view = view }



-- Model


type alias Model =
    { name : String
    , password : String
    , passwordAgain : String
    }


init : Model
init =
    Model "" "" ""


type Msg
    = Name String
    | Password String
    | PasswordAgain String


type PasswordValidation
    = PasswordValid String
    | PasswordDoesNotMatchOnReentry String
    | PasswordNotLongEnough String
    | PasswordNotSecureEnough String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name }

        Password pwd ->
            { model | password = pwd }

        PasswordAgain pwd ->
            { model | passwordAgain = pwd }



-- view


view : Model -> Html Msg
view model =
    div []
        [ viewInput "text" "Name" model.name Name
        , viewInput "password" "Password" model.password Password
        , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
        , viewValidation model
        ]


viewInput : String -> String -> String -> (String -> Msg) -> Html Msg
viewInput inputType placeholderText val toMsg =
    input [ type_ inputType, placeholder placeholderText, value val, onInput toMsg ] []



--  input, div, etc. all take (1) a list of attributes and (2) a list of child nodes.


viewValidation : Model -> Html msg
viewValidation model =
    div []
        (List.map
            (\validation ->
                if model.password /= "" then
                    case validation of
                        PasswordValid successText ->
                            div
                                [ style "color" "green" ]
                                [ text successText ]

                        PasswordDoesNotMatchOnReentry failText ->
                            div
                                [ style "color" "red" ]
                                [ text failText ]

                        PasswordNotLongEnough failText ->
                            div
                                [ style "color" "red" ]
                                [ text failText ]

                        PasswordNotSecureEnough failText ->
                            div
                                [ style "color" "red" ]
                                [ text failText ]

                else
                    div [] []
            )
            (validateModel model)
        )


validateModel : Model -> List PasswordValidation
validateModel model =
    let
        repeatedMatch =
            if model.password == model.passwordAgain then
                PasswordValid "Both passwords match!"

            else
                PasswordDoesNotMatchOnReentry "Passwords do not match!"

        longEnough =
            if String.length model.password > 8 then
                PasswordValid "Greater than 8 characters!"

            else
                PasswordNotLongEnough "Not long enough! Passwords must be greater than 8 characters!"

        secureEnough =
            let
                chars =
                    String.toList model.password

                isSecure =
                    List.foldl (\x y -> x && y)
                        True
                        [ List.any
                            isUpper
                            chars
                        , List.any
                            isLower
                            chars
                        , List.any
                            isDigit
                            chars
                        ]
            in
            if isSecure == True then
                PasswordValid "Secure enough!"

            else
                PasswordNotSecureEnough "Passwords must contain at least 1 uppercase character, 1 lowercase character, and one digit!"
    in
    [ repeatedMatch, longEnough, secureEnough ]
