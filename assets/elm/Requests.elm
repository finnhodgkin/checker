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


createCheckboxRequest : Int -> String -> Cmd Msg
createCheckboxRequest id description =
    let
        url =
            "/checkboxes"
    in
    Http.send (CreateCheckboxDatabase id) (Http.post url (Http.jsonBody <| encodeCheckbox description) (Decode.at [ "data" ] checkboxDecoder))


deleteCheckboxRequest : Int -> Cmd Msg
deleteCheckboxRequest id =
    let
        url =
            "/checkboxes/" ++ toString id

        expectedCheckbox =
            Http.expectJson (Decode.at [ "data" ] checkboxDecoder)

        request =
            Http.request
                { method = "DELETE"
                , headers = []
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectStringResponse (\response -> Ok "")
                , timeout = Nothing
                , withCredentials = False
                }
    in
    Http.send (DeleteCheckboxDatabase id) request


updateCheckbox : Checkbox -> Int -> Cmd Msg
updateCheckbox checkbox id =
    let
        url =
            "/checkboxes/" ++ toString checkbox.id

        body =
            Http.jsonBody <| encodeUpdate checkbox.description

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
    Http.send UpdateCheckboxDatabase request


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
    Http.send UpdateCheckboxDatabase request


updateChecklist : Checklist -> Cmd Msg
updateChecklist list =
    let
        url =
            "/checklist/" ++ toString list.id

        body =
            Http.jsonBody <| encodeList list.title

        expectedChecklist =
            Http.expectJson (Decode.at [ "data" ] listDecoder)

        listRequest =
            Http.request
                { method = "PUT"
                , headers = []
                , url = url
                , body = body
                , expect = expectedChecklist
                , timeout = Nothing
                , withCredentials = False
                }
    in
    Http.send UpdateChecklistDatabase listRequest



-- ENCODERS


encodeUpdate : String -> Value
encodeUpdate description =
    let
        checkbox =
            JE.object
                [ ( "description", JE.string description ) ]
    in
    JE.object
        [ ( "checkbox", checkbox )
        ]


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


encodeList : String -> Value
encodeList title =
    let
        checklist =
            JE.object
                [ ( "title", JE.string title ) ]
    in
    JE.object [ ( "checklist", checklist ) ]



-- DECODERS


listCheckboxesDecoder : Decoder (List Checkbox)
listCheckboxesDecoder =
    Decode.at [ "data" ] (Decode.list checkboxDecoder)


checkboxDecoder : Decoder Checkbox
checkboxDecoder =
    Decode.map6 Checkbox
        (field "description" Decode.string)
        (field "checked" Decode.bool)
        (field "id" Decode.int)
        (field "saved" Decode.bool)
        (field "editing" Decode.bool)
        (field "editString" Decode.string)


listDecoder : Decoder Checklist
listDecoder =
    Decode.at [ "data" ] <|
        Decode.map4 Checklist
            (field "title" Decode.string)
            (field "id" Decode.int)
            (field "editing" Decode.bool)
            (field "editString" Decode.string)
