module View.Question exposing (view)

import Data.Question exposing (Question)
import Html exposing (Html, div, text)
import View.Button exposing (btn)
import View.Form exposing (group)


view : (String -> msg) -> Question -> Html msg
view msg { question, correct, incorrect } =
    let
        answers =
            List.sort (correct :: incorrect)
    in
    div
        []
        [ View.Form.group [ text question ]
        , answers
            |> List.map (\a -> View.Button.btn (msg a) a)
            |> List.intersperse (text " ")
            |> View.Form.group
        ]
