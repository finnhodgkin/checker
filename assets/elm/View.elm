module View exposing (content)

import Authentication exposing (authenticateView)
import Checkbox exposing (checkboxView)
import Checklist exposing (checklistView)
import Html exposing (..)
import Notes exposing (noteView, notesView)
import Types exposing (..)


content : Model -> Html Msg
content model =
    case model.view of
        AuthView ->
            authenticateView model

        ChecklistView ->
            checklistView model

        CheckboxView checklist ->
            checkboxView checklist model

        NotesView ->
            notesView model

        NoteView id ->
            noteView id model
