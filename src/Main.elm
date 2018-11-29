port module Main exposing (Model, init, main, view)

import Array exposing (Array)
import Browser exposing (sandbox)
import Data.Difficulty exposing (Difficulty, default, toString)
import Data.Question exposing (Question)
import Html exposing (Html, div, h1, img, input, option, select, text)
import Html.Attributes exposing (src, style, value)
import Http exposing (Error)
import Request.Helpers exposing (queryString)
import Request.TriviaQuestions exposing (TriviaResults)
import Util exposing (appendIf, onChange)
import View.Button
import View.Question exposing (view)


type alias GameResults =
    { score : Int
    , total : Int
    }



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
            , style "margin-top" "20px"
            ]
            []
        , div [ style "margin-top" "20px" ]
            [ select [ onChange (ChangeDifficulty << Data.Difficulty.get) ]
                (List.map (\key -> option [] [ text key ])
                    Data.Difficulty.keys
                )
            ]
        , div [ style "padding" "20px" ] [ View.Button.btn Start "Start" ]
        , div
            []
            (questions
                |> Array.indexedMap (\i q -> View.Question.view (Answer i) q)
                |> Array.toList
            )
        , View.Button.btn SubmitAnswers "Submit"
        ]



---- PROGRAM ----


type Msg
    = Answer Int String
    | UpdateAmount String
    | ChangeDifficulty Difficulty
    | Start
    | GetQuestions (Result Error TriviaResults)
    | SubmitAnswers
    | SavedGameResults (List GameResults)


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
            , Http.send GetQuestions <|
                Http.get
                    (Request.TriviaQuestions.apiUrl
                        ([ ( "amount", String.fromInt model.amount ) ]
                            |> appendIf (not flag) ( "difficulty", difficultyValue )
                            |> queryString
                        )
                    )
                    Request.TriviaQuestions.decoder
            )

        GetQuestions res ->
            ( case res of
                Ok { questions } ->
                    { model | questions = Array.fromList questions }

                Err err ->
                    model
            , Cmd.none
            )

        SubmitAnswers ->
            let
                length =
                    Array.length model.questions

                score =
                    Array.foldl
                        (\{ userAnswer, correct } acc ->
                            case userAnswer of
                                Just v ->
                                    if v == correct then
                                        acc + 1

                                    else
                                        acc

                                Nothing ->
                                    acc
                        )
                        0
                        model.questions

                res =
                    GameResults score length
            in
            ( model, output res )

        SavedGameResults res ->
            ( model, Cmd.none )


port output : GameResults -> Cmd msg


port incoming : (List GameResults -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    incoming SavedGameResults


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
