port module SaveToStorage exposing (..)

import Json.Decode as JD
import Json.Encode exposing (Value, int, list, object, string)
import Types exposing (..)


port setLists : Value -> Cmd msg


port getChecklists : (Value -> msg) -> Sub msg


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


encodeEditing : Editing -> Value
encodeEditing editing =
    case editing of
        Editing editString ->
            object
                [ ( "edit", string editString )
                ]

        Set ->
            string "Set"
