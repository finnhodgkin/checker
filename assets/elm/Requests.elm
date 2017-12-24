module Requests exposing (..)

import Http
import Json.Decode as Decode exposing (Decoder, bool, dict, field, int, string)
import Json.Encode as JE exposing (Value, bool, int)
import Types exposing (..)


-- REQUESTS


req : String -> String -> String -> Http.Expect a -> Http.Body -> Http.Request a
req url token method expected body =
    Http.request
        { method = method
        , headers = [ Http.header "Authorization" token ]
        , url = url
        , body = body
        , expect = expected
        , timeout = Nothing
        , withCredentials = False
        }


reqGet : String -> String -> Http.Expect a -> Http.Request a
reqGet url token expected =
    req url token "GET" expected Http.emptyBody


reqPost : String -> String -> Http.Expect a -> Http.Body -> Http.Request a
reqPost url token expected body =
    req url token "POST" expected body


reqPut : String -> String -> Http.Expect a -> Http.Body -> Http.Request a
reqPut url token expected body =
    req url token "PUT" expected body


reqDelete : String -> String -> Http.Request String
reqDelete url token =
    req url token "DELETE" (Http.expectStringResponse (\response -> Ok "")) Http.emptyBody


expectedChecklist : Http.Expect Checklist
expectedChecklist =
    Http.expectJson <| Decode.at [ "data" ] checklistDecoder


expectedCheckbox : Http.Expect Checkbox
expectedCheckbox =
    Http.expectJson <| Decode.at [ "data" ] checkboxDecoder


expectedChecklists : Http.Expect (List Checklist)
expectedChecklists =
    Http.expectJson <| listChecklistDecoder


expectedCheckboxes : Http.Expect (List Checkbox)
expectedCheckboxes =
    Http.expectJson <| listCheckboxesDecoder


bodyChecklist : String -> Http.Body
bodyChecklist title =
    Http.jsonBody <| encodeList title


bodyCheckbox : String -> Int -> Http.Body
bodyCheckbox description listId =
    Http.jsonBody <| encodeCheckbox description listId


bodyCheckboxUpdate : String -> Http.Body
bodyCheckboxUpdate description =
    Http.jsonBody <| encodeUpdate description


fetchInitialData : String -> Int -> Cmd Msg
fetchInitialData token id =
    let
        url =
            "/checkboxes?id=" ++ toString id

        request =
            reqGet url token expectedCheckboxes
    in
    Http.send GetAllCheckboxes request


getLists : String -> Cmd Msg
getLists token =
    Http.send ShowLists (reqGet "/checklists" token expectedChecklists)


createChecklist : String -> String -> Cmd Msg
createChecklist token title =
    let
        request =
            reqPost "/checklists" token expectedChecklist (bodyChecklist title)
    in
    Http.send CreateChecklistDatabase request


createCheckboxRequest : String -> Int -> String -> Int -> Cmd Msg
createCheckboxRequest token id description listId =
    let
        body =
            bodyCheckbox description listId

        request =
            reqPost "/checkboxes" token expectedCheckbox body
    in
    Http.send (CreateCheckboxDatabase id description) request


deleteCheckboxRequest : String -> Int -> Cmd Msg
deleteCheckboxRequest token id =
    let
        url =
            "/checkboxes/" ++ toString id
    in
    Http.send (DeleteCheckboxDatabase id) (reqDelete url token)


updateCheckboxDatabase : String -> Checkbox -> Int -> Cmd Msg
updateCheckboxDatabase token checkbox id =
    let
        url =
            "/checkboxes/" ++ toString checkbox.id

        body =
            bodyCheckboxUpdate checkbox.description

        request =
            reqPut url token expectedCheckbox body
    in
    Http.send (UpdateCheckboxDatabase checkbox) request


checkToggle : String -> Int -> Bool -> Cmd Msg
checkToggle token id checked =
    let
        url =
            "/checkboxes/" ++ toString id

        body =
            Http.jsonBody <| encodeToggle id checked

        request =
            reqPut url token expectedCheckbox body

        checkbox =
            Checkbox "" checked id Saved Set NoAnimation
    in
    Http.send (UpdateCheckboxDatabase checkbox) request


checkboxUpdateBoth : String -> Checkbox -> Cmd Msg
checkboxUpdateBoth token checkbox =
    let
        url =
            "/checkboxes/" ++ toString checkbox.id

        body =
            Http.jsonBody <| encodeCheckboxNoList checkbox.description checkbox.checked

        request =
            reqPut url token expectedCheckbox body
    in
    Http.send (UpdateCheckboxDatabase checkbox) request


updateChecklist : String -> Checklist -> Cmd Msg
updateChecklist token list =
    let
        url =
            "/checklists/" ++ toString list.id

        description =
            case list.editing of
                Editing str ->
                    str

                _ ->
                    ""

        request =
            reqPut url token expectedChecklist (bodyChecklist description)
    in
    if description == "" then
        Cmd.none
    else
        Http.send UpdateChecklistDatabase request


deleteChecklist : Model -> Cmd Msg
deleteChecklist model =
    let
        listId =
            toString model.checklist.id

        request =
            reqDelete ("/checklists/" ++ listId) model.auth.token
    in
    Http.send (DeleteChecklistDatabase model.checklist.id) request



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


encodeCheckbox : String -> Int -> Value
encodeCheckbox description checklistId =
    encodeCheckboxAll description False checklistId


encodeCheckboxNoList : String -> Bool -> Value
encodeCheckboxNoList description checked =
    let
        checkbox =
            JE.object
                [ ( "checked", JE.bool checked )
                , ( "description", JE.string description )
                ]
    in
    JE.object
        [ ( "checkbox", checkbox ) ]


encodeCheckboxAll : String -> Bool -> Int -> Value
encodeCheckboxAll description checked checklistId =
    let
        checkbox =
            JE.object
                [ ( "description", JE.string description )
                , ( "checked", JE.bool checked )
                , ( "checklist_id", JE.int checklistId )
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


listChecklistDecoder : Decoder (List Checklist)
listChecklistDecoder =
    Decode.at [ "data" ] (Decode.list checklistDecoder)


checklistDecoder : Decoder Checklist
checklistDecoder =
    Decode.map3
        Checklist
        (field "title" Decode.string)
        (field "id" Decode.int)
        (field "editing" Decode.string |> setSucceed Set)


listCheckboxesDecoder : Decoder (List Checkbox)
listCheckboxesDecoder =
    Decode.at [ "data" ] (Decode.list checkboxDecoder)


setSucceed : a -> Decoder b -> Decoder a
setSucceed value =
    Decode.andThen (\_ -> Decode.succeed value)


checkboxDecoder : Decoder Checkbox
checkboxDecoder =
    let
        animate string =
            case string of
                "create" ->
                    Create

                "delete" ->
                    Delete

                _ ->
                    NoAnimation
    in
    Decode.map6 Checkbox
        (field "description" Decode.string)
        (field "checked" Decode.bool)
        (field "id" Decode.int)
        (field "saved" Decode.bool |> setSucceed Saved)
        (field "editing" Decode.bool |> setSucceed Set)
        (field "animate" Decode.string
            |> Decode.andThen (\str -> Decode.succeed (animate str))
        )


listDecoder : Decoder Checklist
listDecoder =
    Decode.map3
        Checklist
        (field "title" Decode.string)
        (field "id" Decode.int)
        (field "editing" Decode.string |> Decode.andThen (\str -> Decode.succeed Set))
