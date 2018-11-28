module Main exposing (Model, init, main, view)

import Browser
import Data.Difficulty exposing (Difficulty, default)
import Data.Question exposing (Question)
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import View.Question exposing (view)



---- MODEL ----


type alias Model =
    { difficulty : Difficulty
    , questions : List Question
    }


init : Model
init =
    Model
        default
        [ Question
            (Just "To get to the other sides")
            "Why did the chicken cross the road?"
            "Keith Sucks"
            [ "Keith Doesn't Suck" ]
        ]



---- UPDATE ----
---- VIEW ----


view : Model -> Html msg
view { questions } =
    questions
        |> List.map
            (\{ question, correct } ->
                "Question: " ++ question ++ " Answer: " ++ correct
            )
        |> String.join ", "
        |> text



---- PROGRAM ----


main : Html msg
main =
    div [] (List.map View.Question.view init.questions)



-- init.questions
--     |> List.map View.Question.view
--     |> String.join ", "
--     |> text
