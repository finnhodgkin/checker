module NoteHelpers exposing (..)

import Helpers exposing (createUniqueId)
import NoteTypes exposing (..)
import Types exposing (..)


updateCurrentNote : Int -> Model -> Model
updateCurrentNote id model =
    { model | currentNote = Just id }


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
                | currentNote = Just id
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


updateClearNote : Model -> Model
updateClearNote model =
    { model | currentNote = Nothing }


updateTitle : String -> Model -> Model
updateTitle text model =
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


updateNote : String -> Model -> Model
updateNote text model =
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


updateRows : Int -> Model -> Model
updateRows rows model =
    { model | noteRows = getRows rows }


getRows : Int -> Int
getRows scrollHeight =
    (toFloat scrollHeight * 1.5)
        / 25
        |> ceiling
