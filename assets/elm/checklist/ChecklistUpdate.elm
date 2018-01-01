module ChecklistUpdate exposing (checklistUpdate)

import AuthenticationUpdate exposing (..)
import Checkbox exposing (focusElement)
import Checklist exposing (getEditString)
import CommandHelpers exposing (..)
import Helpers exposing (..)
import Requests exposing (..)
import SaveToStorage exposing (encodeListChecklist, fetchCheckboxesFromLS, setLists)
import Types exposing (..)


checklistUpdate : Msg -> Model -> ( Model, Cmd Msg )
checklistUpdate msg model =
    case msg of
        CreateChecklist ->
            model
                |> updateCreateList ""
                |> updateList (Checklist model.createChecklist 1 Set)
                |> updateListStatus Unsaved
                |> cmd
                |> cmdCreateChecklist
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
                |> updateCheckboxLoaded Loading
                |> cmd
                |> cmdFetchFromBoth
                |> cmdSend

        EditChecklist ->
            model
                |> updateList (startListEdit model.checklist)
                |> cmd
                |> cmdFocus "title-input"
                |> cmdSend

        UpdateChecklist newTitle ->
            model
                |> updateList (updateListEditing newTitle model.checklist)
                |> cmdNone

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
                |> cmdNone

        SetChecklist ->
            let
                setIfEditing list =
                    case getEditString model.checklist.editing of
                        Just str ->
                            ( { list | editing = Set, title = str }
                            , updateChecklist model.auth.token model.checklist
                            )

                        Nothing ->
                            ( list
                            , Cmd.none
                            )

                ( list, update ) =
                    setIfEditing model.checklist
            in
            (model |> updateList list) ! [ update ]

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

        _ ->
            authenticationUpdate msg model
