module NotesUpdate exposing (..)

import NoteTypes exposing (..)
import Types exposing (..)


notesUpdate : Msg -> Model -> ( Model, Cmd Msg )
notesUpdate msg model =
    case msg of
        UpdateCurrentNote text ->
            model ! []

        SetCurrerntNote id ->
            model ! []

        _ ->
            model ! []
