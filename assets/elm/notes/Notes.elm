module Notes exposing (..)

import Helpers exposing (findById)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Json.Decode as JD exposing (..)
import NoteTypes exposing (..)
import Types exposing (..)


noteView : Int -> Model -> Html Msg
noteView id model =
    let
        ( noteText, noteTitle ) =
            findById id model.notes
                |> Maybe.map (\note -> ( note.note, note.title ))
                |> Maybe.withDefault ( "", "Untitled" )
    in
    div [ class "notes" ]
        [ div [ class "notes__title" ]
            [ i [ onClick SetNotesView, class "material-icons" ] [ text "chevron_left" ]
            , text noteTitle
            ]
        , textarea [ class "notes__text", on "input" noteInputDecoder ]
            [ text noteText ]
        ]


noteInputDecoder : Decoder Msg
noteInputDecoder =
    JD.map Notes
        (JD.map2 NewValues
            (JD.at [ "target", "value" ] JD.string)
            (JD.at [ "target", "scrollHeight" ] JD.int)
        )


notesTitle : Model -> Html Msg
notesTitle model =
    let
        title =
            case model.createNote of
                Editing string ->
                    [ Html.form [ class "notes-list__form", onSubmit (Notes <| CreateNote) ]
                        [ backButton
                        , input
                            [ class "notes-list__input"
                            , onInput (Notes << UpdateCreateNote)
                            , HA.value string
                            , id "note-edit"
                            ]
                            []
                        , button [ class "material-icons notes-title__submit" ] [ text "add" ]
                        ]
                    ]

                Set ->
                    [ backButton
                    , h2 [ class "notes-title" ] [ text "Notes" ]
                    , i
                        [ class "material-icons notes-title__add"
                        , onClick (Notes <| SetNoteEdit)
                        ]
                        [ text "note_add" ]
                    ]
    in
    section [ class "notes-title-wrap" ] title


backButton : Html Msg
backButton =
    Html.i
        [ class "material-icons notes-title__back", onClick SetChecklistView ]
        [ text "chevron_left" ]


notesView : Model -> Html Msg
notesView model =
    section
        [ class "notes-list-wrap fade_in_fast" ]
        [ notesTitle model
        , ul [ class "notes-list" ]
            (List.map
                (\note ->
                    li [ class "notes-list__item", onClick (Notes <| SetNote note.id) ]
                        [ text note.title ]
                )
                model.notes
            )
        ]
