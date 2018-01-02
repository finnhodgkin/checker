module Notes exposing (..)

import Helpers exposing (findById)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Types exposing (..)


notes : Model -> Html Msg
notes model =
    case model.currentNote of
        Just id ->
            note id model

        Nothing ->
            showNoteList model


note : Int -> Model -> Html Msg
note id model =
    let
        noteText =
            findById id model.notes
                |> Maybe.map (\note -> note.note)
                |> Maybe.withDefault ""
    in
    textarea [ class "notes", onInput UpdateCurrentNote ]
        [ text noteText ]


showNoteList : Model -> Html Msg
showNoteList model =
    ul []
        (List.map
            (\note ->
                li [ onClick (SetCurrentNote note.id) ]
                    [ text note.title ]
            )
            model.notes
        )
