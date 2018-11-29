module Data.Difficulty exposing (Difficulty, default, get, keys)


type Difficulty
    = Any
    | Easy
    | Medium
    | Hard


default : Difficulty
default =
    Any


list : List ( String, Difficulty )
list =
    [ ( "Any", Any )
    , ( "Easy", Easy )
    , ( "Medium", Medium )
    , ( "Hard", Hard )
    ]


keys : List String
keys =
    list
        |> List.unzip
        |> Tuple.first


get : String -> Difficulty
get key =
    list
        |> List.filter (\( k, v ) -> k == key)
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault default
