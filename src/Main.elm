module Main exposing (Model, init, main, view)

import Array exposing (Array)
import Browser exposing (sandbox)
import Data.Difficulty exposing (Difficulty, default)
import Data.Question exposing (Question)
import Html exposing (Html, div, h1, img, input, option, select, text)
import Html.Attributes exposing (src, value)
import Http exposing (Error)
import Json.Decode exposing (Value)
import Request.Helpers exposing (queryString)
import Request.TriviaQuestions
import Util exposing (appendIf, onChange)
import View.Button
import View.Question exposing (view)



---- MODEL ----


type alias Flags =
    Int


type alias Model =
    { amount : Int
    , difficulty : Difficulty
    , questions : Array Question
    }


init : Flags -> ( Model, Cmd Msg )
init flgs =
    ( Model
        flgs
        Data.Difficulty.default
        Array.empty
    , Cmd.none
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
        , View.Button.btn Start "Start"
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
    | Start
    | GetQuestions (Result Error Value)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Answer i val ->
            ( model.questions
                |> Array.get i
                |> Maybe.map (\q -> { q | userAnswer = Just val })
                |> Maybe.map (\q -> Array.set i q model.questions)
                |> Maybe.map (\arr -> { model | questions = arr })
                |> Maybe.withDefault model
            , Cmd.none
            )

        UpdateAmount str ->
            Maybe.withDefault 0 (String.toInt str)
                |> (\val ->
                        if val > 50 then
                            ( { model | amount = 50 }
                            , Cmd.none
                            )

                        else
                            ( { model | amount = val }
                            , Cmd.none
                            )
                   )

        ChangeDifficulty lvl ->
            ( { model | difficulty = lvl }
            , Cmd.none
            )

        Start ->
            let
                difficultyValue =
                    model.difficulty
                        |> Data.Difficulty.toString
                        |> String.toLower

                flag =
                    Data.Difficulty.isAny model.difficulty
            in
            ( model
            , Cmd.none
            )

        GetQuestions res ->
            ( model, Cmd.none )


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
