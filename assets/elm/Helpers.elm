module Helpers exposing (..)

import Json.Decode as JD exposing (..)


decodeStringToUnion : (String -> a) -> Decoder a
decodeStringToUnion typeCaseFunction =
    JD.string
        |> JD.andThen (\str -> JD.succeed (typeCaseFunction str))


findById : Int -> List { b | id : Int } -> Maybe { b | id : Int }
findById id list =
    List.head (List.filter (\item -> item.id == id) list)
