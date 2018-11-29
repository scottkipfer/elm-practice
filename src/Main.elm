module Main exposing (Model, init, main, view)

import Array exposing (Array)
import Browser exposing (sandbox)
import Data.Difficulty exposing (Difficulty, default)
import Data.Question exposing (Question)
import Html exposing (Html, div, h1, img, input, option, select, text)
import Html.Attributes exposing (src, value)
import Util exposing (onChange)
import View.Question exposing (view)



---- MODEL ----


type alias Model =
    { amount : Int
    , difficulty : Difficulty
    , questions : Array Question
    }


init : Model
init =
    Model
        5
        Data.Difficulty.default
        (Array.fromList
            [ Question
                (Just "To get to the other sides")
                "Why did the chicken cross the road?"
                "Keith Sucks"
                [ "Keith Doesn't Suck", "Keith Might Suck" ]
            , Question
                (Just "To get to the other sides")
                "Why did the chicken cross the road?"
                "Keith Sucks"
                [ "Keith Doesn't Suck", "Keith Might Suck" ]
            ]
        )



---- UPDATE ----
---- VIEW ----


view : Model -> Html Msg
view { amount, questions } =
    div
        []
        [ input
            [ onChange UpdateAmount
            , value (String.fromInt amount)
            ]
            []
        , select [ onChange (ChangeDifficulty << Data.Difficulty.get) ]
            (List.map (\key -> option [] [ text key ])
                Data.Difficulty.keys
            )
        , div
            []
            (questions
                |> Array.indexedMap (\i q -> View.Question.view (Answer i) q)
                |> Array.toList
            )
        ]



---- PROGRAM ----


type Msg
    = Answer Int String
    | UpdateAmount String
    | ChangeDifficulty Difficulty


update : Msg -> Model -> Model
update msg model =
    case msg of
        Answer i val ->
            model.questions
                |> Array.get i
                |> Maybe.map (\q -> { q | userAnswer = Just val })
                |> Maybe.map (\q -> Array.set i q model.questions)
                |> Maybe.map (\arr -> { model | questions = arr })
                |> Maybe.withDefault model

        UpdateAmount str ->
            Maybe.withDefault 0 (String.toInt str)
                |> (\val ->
                        if val > 50 then
                            { model | amount = 50 }

                        else
                            { model | amount = val }
                   )

        ChangeDifficulty lvl ->
            { model | difficulty = lvl }


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }



-- init.questions
--     |> List.map View.Question.view
--     |> String.join ", "
--     |> text
