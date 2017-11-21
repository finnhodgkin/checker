module Requests exposing (..)

import Http
import Json.Decode as Decode exposing (Decoder, bool, field, int, string)
import Json.Encode as JE exposing (Value, bool, int)
import Types exposing (..)


-- REQUESTS


fetchInitialData : Cmd Msg
fetchInitialData =
    let
        url =
            "/checkboxes"
    in
    Http.send GetAll (Http.get url listCheckboxesDecoder)


createCheckboxRequest : String -> Cmd Msg
createCheckboxRequest description =
    let
        url =
            "/checkboxes"
    in
    Http.send CreateCheckboxDatabase (Http.post url (Http.jsonBody <| encodeCheckbox description) (Decode.at [ "data" ] checkboxDecoder))


checkToggle : Int -> Bool -> Cmd Msg
checkToggle id checked =
    let
        url =
            "/checkboxes/" ++ toString id

        body =
            Http.jsonBody <| encodeToggle id checked

        expectedCheckbox =
            Http.expectJson (Decode.at [ "data" ] checkboxDecoder)

        request =
            Http.request
                { method = "PUT"
                , headers = []
                , url = url
                , body = body
                , expect = expectedCheckbox
                , timeout = Nothing
                , withCredentials = False
                }
    in
    Http.send CheckDatabase request



-- ENCODERS


encodeToggle : Int -> Bool -> Value
encodeToggle id checked =
    let
        checkbox =
            JE.object
                [ ( "id", JE.int id )
                , ( "checked", JE.bool checked )
                ]
    in
    JE.object
        [ ( "checkbox", checkbox )
        ]


encodeCheckbox : String -> Value
encodeCheckbox description =
    let
        checkbox =
            JE.object
                [ ( "description", JE.string description )
                , ( "checked", JE.bool False )
                ]
    in
    JE.object
        [ ( "checkbox", checkbox ) ]



-- DECODERS


listCheckboxesDecoder : Decoder (List Checkbox)
listCheckboxesDecoder =
    Decode.at [ "data" ] (Decode.list checkboxDecoder)


checkboxDecoder : Decoder Checkbox
checkboxDecoder =
    Decode.map3 Checkbox
        (field "description" Decode.string)
        (field "checked" Decode.bool)
        (field "id" Decode.int)
