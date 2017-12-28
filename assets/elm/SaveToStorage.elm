port module SaveToStorage exposing (..)

import Json.Decode as JD
import Json.Encode exposing (Value, bool, int, list, object, string)
import Types exposing (..)


port setLists : Value -> Cmd msg


port getChecklists : (Value -> msg) -> Sub msg


port setCheckboxes : Value -> Cmd msg


port getCheckboxes : Value -> Cmd msg


port sendStoredCheckboxes : (Value -> msg) -> Sub msg



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
            BadDecode (toString error)


checkboxDecoder : JD.Decoder Checkbox
checkboxDecoder =
    JD.map6 Checkbox
        (JD.field "description" JD.string)
        (JD.field "checked" JD.bool)
        (JD.field "id" JD.int)
        (JD.field "saved" JD.string
            |> JD.andThen (\str -> JD.succeed (decodeStatus str))
        )
        (JD.field "editing"
            (JD.oneOf
                [ JD.field "edit" JD.string
                    |> JD.andThen (\str -> JD.succeed (Editing str))
                , JD.succeed Set
                ]
            )
        )
        (JD.field "animate" JD.string
            |> JD.andThen (\str -> JD.succeed (decodeAnimate str))
        )


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
                        (JD.field "editing"
                            (JD.oneOf
                                [ JD.field "edit" JD.string
                                    |> JD.andThen (\str -> JD.succeed (Editing str))
                                , JD.succeed Set
                                ]
                            )
                        )
                    )
                )
                checklists
    in
    case decoded of
        Ok value ->
            ShowLists (Ok value)

        Err error ->
            BadDecode (toString error)


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


decodeStatus : String -> Status
decodeStatus status =
    case status of
        "Saved" ->
            Saved

        "Unloaded" ->
            Unloaded

        _ ->
            Unsaved


decodeAnimate : String -> Animate
decodeAnimate animate =
    case animate of
        "Create" ->
            Create

        "Delete" ->
            Delete

        _ ->
            NoAnimation



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
