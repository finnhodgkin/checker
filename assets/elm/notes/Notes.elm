module Notes exposing (..)

import Helpers exposing (findById)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Json.Decode as JD exposing (..)
import NoteTypes exposing (..)
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
        ( noteText, noteTitle ) =
            findById id model.notes
                |> Maybe.map (\note -> ( note.note, note.title ))
                |> Maybe.withDefault ( "", "" )
    in
    div [ class "notes" ]
        [ div [ class "notes__title" ]
            [ i [ onClick (Notes <| ClearNote), class "material-icons" ] [ text "chevron_left" ]
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
                        [ input
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
                    [ h2 [ class "notes-title" ] [ text "Notes" ]
                    , i
                        [ class "material-icons notes-title__add"
                        , onClick (Notes <| SetNoteEdit)
                        ]
                        [ text "note_add" ]
                    ]
    in
    section [ class "notes-title-wrap" ] title


showNoteList : Model -> Html Msg
showNoteList model =
    section [ class "notes-list-wrap" ]
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
