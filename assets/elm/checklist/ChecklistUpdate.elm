module ChecklistUpdate exposing (checklistUpdate)

import AuthenticationUpdate exposing (..)
import CommandHelpers exposing (..)
import Helpers exposing (..)
import Requests exposing (..)
import Types exposing (..)


checklistUpdate : Msg -> Model -> ( Model, Cmd Msg )
checklistUpdate msg model =
    let
        checklist =
            currentChecklist model
    in
    case msg of
        CreateChecklist ->
            let
                title =
                    model.createChecklist
            in
            model
                |> updateCreateList ""
                |> updateList (Checklist model.createChecklist 1 Set)
                |> updateListStatus Unsaved
                |> cmd
                |> cmdCreateChecklist title
                |> cmdSend

        CreateChecklistDatabase (Ok checklist) ->
            model
                |> updateList checklist
                |> updateLists (model.checklists ++ [ checklist ])
                |> updateListStatus Saved
                |> updateCheckboxLoaded Loaded
                |> cmd
                |> cmdSetLists
                |> cmdSend

        CreateChecklistDatabase (Err err) ->
            model
                |> updateError (toString err)
                |> cmdNone

        UpdateCreateChecklist listName ->
            model
                |> updateCreateList listName
                |> cmdNone

        SetList checklist ->
            model
                |> updateList checklist
                |> updateListToLists
                |> updateCheckboxLoaded Loading
                |> cmd
                |> cmdFetchFromBoth
                |> cmdSend

        EditChecklist ->
            model
                |> updateList (startListEdit checklist)
                |> cmd
                |> cmdFocus "title-input"
                |> cmdSend

        UpdateChecklist newTitle ->
            model
                |> updateList (updateListEditing newTitle checklist)
                |> cmd
                |> cmdSetLists
                |> cmdSend

        DeleteChecklist ->
            model
                |> updateChecks []
                |> cmd
                |> cmdDeleteList
                |> cmdSend

        DeleteChecklistDatabase id (Ok checklist) ->
            model
                |> updateLists (deleteById id model.checklists)
                |> updateList (Checklist "" 0 Set)
                |> updateChecklistAnimNone
                |> updateChecklistView
                |> cmd
                |> cmdSetLists
                |> cmdSend

        DeleteChecklistDatabase id (Err err) ->
            model
                |> updateError (toString err)
                |> cmdNone

        ResetChecklist ->
            model
                |> updateList (Checklist "" 0 Set)
                |> updateChecks []
                |> updateCheckboxLoaded Empty
                |> updateChecklistView
                |> updateChecklistAnimNone
                |> cmdNone

        SetChecklist ->
            let
                setIfEditing list =
                    case list.editing of
                        Editing str ->
                            ( { list | editing = Set, title = str }
                            , updateChecklist model.auth.token checklist
                            )

                        Set ->
                            ( list
                            , Cmd.none
                            )

                ( list, update ) =
                    setIfEditing checklist
            in
            (model
                |> updateList list
                |> updateListToLists
            )
                ! [ update ]

        UpdateChecklistDatabase (Ok checklist) ->
            model
                |> updateList checklist
                |> cmdNone

        UpdateChecklistDatabase (Err err) ->
            model
                |> updateError (toString err)
                |> updateCheckboxLoaded Empty
                |> cmdNone

        ShowLists (Ok checklists) ->
            model
                |> updateLists checklists
                |> updateCheckboxLoaded Empty
                |> cmd
                |> cmdSetLists
                |> cmdSend

        ShowLists (Err err) ->
            model
                |> updateError (toString err)
                |> cmdNone

        PreNotesView ->
            model
                |> updateChecklistAnimDelete
                |> cmdNone

        _ ->
            authenticationUpdate msg model
