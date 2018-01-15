module NotesUpdate exposing (..)

import CommandHelpers exposing (cmd, cmdFocus, cmdNone, cmdSend)
import NoteHelpers exposing (..)
import NoteTypes exposing (..)
import Types exposing (..)


notesUpdate : NoteMsg -> Model -> ( Model, Cmd Msg )
notesUpdate msg model =
    case msg of
        UpdateNote text ->
            model
                |> updateNote text
                |> cmdNone

        SetNote id ->
            model
                |> updateNoteView id
                |> cmdNone

        UpdateTitle text ->
            model
                |> updateTitle text
                |> cmdNone

        NewValues text num ->
            model
                |> updateNote text
                |> updateRows num
                |> cmdNone

        CreateNote ->
            model
                |> updateCreateNote
                |> cmdNone

        UpdateCreateNote title ->
            model
                |> updateCreateNoteString title
                |> cmdNone

        SetNoteEdit ->
            model
                |> updateSetNoteEdit
                |> cmd
                |> cmdFocus "note-edit"
                |> cmdSend
