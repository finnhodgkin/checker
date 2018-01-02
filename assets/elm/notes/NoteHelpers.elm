module NoteHelpers exposing (..)

import Types exposing (..)


updateCurrentNote : Int -> Model -> Model
updateCurrentNote id model =
    { model | currentNote = Just id }


updateNoteTitle : String -> Model -> Model
updateNoteTitle text model =
    let
        currentId =
            Maybe.withDefault -1 model.currentNote

        updateNote note =
            if currentId == note.id then
                { note | title = text }
            else
                note
    in
    { model | notes = List.map updateNote model.notes }


updateNoteNote : String -> Model -> Model
updateNoteNote text model =
    let
        currentId =
            Maybe.withDefault -1 model.currentNote

        updateNote note =
            if currentId == note.id then
                { note | note = text }
            else
                note
    in
    { model | notes = List.map updateNote model.notes }
