port module SaveToStorage exposing (..)

import Json.Encode exposing (Value, int, list, object, string)
import Types exposing (..)


port setLists : Value -> Cmd msg


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


encodeEditing : Editing -> Value
encodeEditing editing =
    case editing of
        Editing editString ->
            object
                [ ( "edit", string editString )
                ]

        Set ->
            string "Set"
