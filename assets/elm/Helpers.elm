module Helpers exposing (..)

import Json.Decode as JD exposing (..)


decodeStringToUnion : (String -> a) -> Decoder a
decodeStringToUnion typeCaseFunction =
    JD.string
        |> JD.andThen (\str -> JD.succeed (typeCaseFunction str))
