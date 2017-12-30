port module SaveToStorage exposing (..)

import Helpers exposing (decodeStringToUnion)
import Json.Decode as JD
import Json.Encode exposing (Value, bool, int, list, null, object, string)
import Types exposing (..)


port setLists : Value -> Cmd msg


port getChecklists : (Value -> msg) -> Sub msg


port setCheckboxes : Value -> Cmd msg


port getCheckboxes : Value -> Cmd msg


port sendStoredCheckboxes : (Value -> msg) -> Sub msg


port getFailures : (Value -> msg) -> Sub msg


port setFailures : Value -> Cmd msg


port clearFailures : Value -> Cmd msg



-- Failures


clearSavedFailures : Cmd msg
clearSavedFailures =
    clearFailures (bool True)


saveFailures : List Failure -> Cmd msg
saveFailures failures =
    setFailures (encodeListFailures failures)


decodeListFailures : JD.Value -> Msg
decodeListFailures failures =
    let
        decoded =
            JD.decodeValue (JD.list failureDecoder) failures
    in
    case decoded of
        Ok value ->
            GetAllFailures value

        Err error ->
            BadFailureDecode (toString error)


failureDecoder : JD.Decoder Failure
failureDecoder =
    JD.oneOf
        [ JD.at [ "failure" ] (JD.map CheckboxFailure <| decodeCheckUpdate)
        , JD.at [ "failure" ] (JD.map ChecklistFailure <| decodeChecklistUpdate)
        ]


decodeCheckUpdate : JD.Decoder CheckUpdate
decodeCheckUpdate =
    JD.map5
        CheckUpdate
        (JD.field "description" (JD.nullable JD.string))
        (JD.field "checked" JD.bool)
        (JD.field "id" JD.int)
        (JD.field "listId" JD.int)
        (JD.field "command" decodeCommand)


decodeChecklistUpdate : JD.Decoder ChecklistUpdate
decodeChecklistUpdate =
    JD.map3
        ChecklistUpdate
        (JD.field "title" (JD.nullable JD.string))
        (JD.field "id" JD.int)
        (JD.field "command" decodeCommand)


decodeCommand : JD.Decoder Request
decodeCommand =
    let
        commandType command =
            case command of
                "DELETE" ->
                    DELETE

                "CREATE" ->
                    CREATE

                "EDIT" ->
                    EDIT

                "SAVE" ->
                    SAVE

                _ ->
                    DELETE
    in
    JD.string
        |> JD.andThen (\str -> JD.succeed (commandType str))


encodeListFailures : List Failure -> Value
encodeListFailures failures =
    list (List.map encodeFailure failures)


encodeFailure : Failure -> Value
encodeFailure failure =
    case failure of
        CheckboxFailure checkbox ->
            object
                [ ( "type", string "checkbox" )
                , ( "failure", encodeCheckboxFailure checkbox )
                ]

        ChecklistFailure checklist ->
            object
                [ ( "type", string "checklist" )
                , ( "failure", encodeChecklistFailure checklist )
                ]


encodeCheckboxFailure : CheckUpdate -> Value
encodeCheckboxFailure failure =
    object
        [ ( "description", encodeTitle failure.description )
        , ( "checked", bool failure.checked )
        , ( "id", int failure.id )
        , ( "listId", int failure.listId )
        , ( "command", encodeUnion failure.command )
        ]


encodeChecklistFailure : ChecklistUpdate -> Value
encodeChecklistFailure failure =
    object
        [ ( "title", encodeTitle failure.title )
        , ( "id", int failure.id )
        , ( "command", encodeUnion failure.command )
        ]


encodeTitle : Maybe String -> Value
encodeTitle title =
    case title of
        Just str ->
            string str

        Nothing ->
            null



-- Checkboxes


fetchCheckboxesFromLS : Int -> Cmd msg
fetchCheckboxesFromLS listId =
    getCheckboxes (int listId)


decodeListCheckbox : JD.Value -> Msg
decodeListCheckbox checkboxes =
    let
        decoded =
            JD.decodeValue (JD.list checkboxDecoder) checkboxes
    in
    case decoded of
        Ok value ->
            GetAllCheckboxes (Ok value)

        Err error ->
            BadBoxDecode (toString error)


checkboxDecoder : JD.Decoder Checkbox
checkboxDecoder =
    JD.map6 Checkbox
        (JD.field "description" JD.string)
        (JD.field "checked" JD.bool)
        (JD.field "id" JD.int)
        (JD.field "saved" decodeStatus)
        (JD.field "editing" decodeEditing)
        (JD.field "animate" decodeAnimate)


encodeCheckboxes : Int -> List Checkbox -> Value
encodeCheckboxes id checkboxes =
    object
        [ ( "id", int id )
        , ( "checkboxes", encodeListCheckbox checkboxes )
        ]


encodeListCheckbox : List Checkbox -> Value
encodeListCheckbox checkboxes =
    list (List.map encodeCheckbox checkboxes)


encodeCheckbox : Checkbox -> Value
encodeCheckbox checkbox =
    object
        [ ( "description", string checkbox.description )
        , ( "id", int checkbox.id )
        , ( "checked", bool checkbox.checked )
        , ( "saved", encodeUnion checkbox.saved )
        , ( "editing", encodeEditing checkbox.editing )
        , ( "animate", encodeUnion checkbox.animate )
        ]



-- Checklists


decodeListChecklist : JD.Value -> Msg
decodeListChecklist checklists =
    let
        decoded =
            JD.decodeValue
                (JD.list
                    (JD.map3
                        Checklist
                        (JD.field "title" JD.string)
                        (JD.field "id" JD.int)
                        (JD.field "editing" decodeEditing)
                    )
                )
                checklists
    in
    case decoded of
        Ok value ->
            ShowLists (Ok value)

        Err error ->
            BadListDecode (toString error)


encodeListChecklist : List Checklist -> Value
encodeListChecklist checklists =
    list (List.map encodeChecklist checklists)


encodeChecklist : Checklist -> Value
encodeChecklist checklist =
    object
        [ ( "id", int checklist.id )
        , ( "title", string checklist.title )
        , ( "editing", encodeEditing checklist.editing )
        ]



-- Shared decoders


decodeEditing : JD.Decoder Editing
decodeEditing =
    JD.oneOf
        [ JD.field "edit" (decodeStringToUnion Editing)
        , JD.succeed Set
        ]


decodeStatus : JD.Decoder Status
decodeStatus =
    let
        statusType status =
            case status of
                "Saved" ->
                    Saved

                "Unloaded" ->
                    Unloaded

                _ ->
                    Unsaved
    in
    decodeStringToUnion statusType


decodeAnimate : JD.Decoder Animate
decodeAnimate =
    let
        animateType animate =
            case animate of
                "Create" ->
                    Create

                "Delete" ->
                    Delete

                _ ->
                    NoAnimation
    in
    decodeStringToUnion animateType



-- Shared encoders


encodeEditing : Editing -> Value
encodeEditing editing =
    case editing of
        Editing editString ->
            object
                [ ( "edit", string editString )
                ]

        Set ->
            string "Set"


encodeUnion : a -> Value
encodeUnion animate =
    string (toString animate)
