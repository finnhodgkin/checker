module NoteHelpers exposing (..)

import Helpers exposing (createUniqueId)
import NoteTypes exposing (..)
import Types exposing (..)


updateNoteView : Int -> Model -> Model
updateNoteView id model =
    { model | view = NoteView id }


updateCreateNote : Model -> Model
updateCreateNote model =
    let
        id =
            createUniqueId -1 model.notes
    in
    case model.createNote of
        Editing "" ->
            { model | createNote = Set }

        Editing title ->
            { model
                | view = NoteView id
                , notes = model.notes ++ [ Note "" title id ]
                , createNote = Set
            }

        Set ->
            model


updateSetNoteEdit : Model -> Model
updateSetNoteEdit model =
    { model | createNote = Editing "" }


updateCreateNoteString : String -> Model -> Model
updateCreateNoteString string model =
    { model | createNote = Editing string }


updateNotesView : Model -> Model
updateNotesView model =
    { model | view = NotesView }


updateTitle : String -> Model -> Model
updateTitle text model =
    let
        currentId =
            case model.view of
                NoteView id ->
                    id

                _ ->
                    -1

        updateNote note =
            if currentId == note.id then
                { note | title = text }
            else
                note
    in
    { model | notes = List.map updateNote model.notes }


updateNote : String -> Model -> Model
updateNote text model =
    let
        currentId =
            case model.view of
                NoteView id ->
                    id

                _ ->
                    -1

        updateNote note =
            if currentId == note.id then
                { note | note = text }
            else
                note
    in
    { model | notes = List.map updateNote model.notes }


updateRows : Int -> Model -> Model
updateRows rows model =
    { model | noteRows = getRows rows }


getRows : Int -> Int
getRows scrollHeight =
    (toFloat scrollHeight * 1.5)
        / 25
        |> ceiling
