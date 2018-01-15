module CheckboxUpdate exposing (checkboxUpdate)

import ChecklistUpdate exposing (checklistUpdate)
import CommandHelpers
    exposing
        ( cmd
        , cmdCheckToggle
        , cmdCreateCheckboxDatabase
        , cmdDeleteCheckboxRequest
        , cmdFocus
        , cmdNone
        , cmdSaveChecks
        , cmdSaveFailedPosts
        , cmdSend
        , cmdSendEditToDatabase
        )
import DatabaseFailures exposing (..)
import Helpers exposing (..)
import Http
import Types exposing (..)


-- Update


checkboxUpdate : Msg -> Model -> ( Model, Cmd Msg )
checkboxUpdate msg model =
    let
        checklist =
            case model.view of
                CheckboxView checklist ->
                    checklist

                _ ->
                    Checklist "" 0 Set
    in
    case msg of
        Check id ->
            model
                |> updateChecks (toggleChecked id model.checks)
                |> cmd
                |> cmdSaveChecks
                |> cmdCheckToggle id
                |> cmdSend

        SetEditCheckbox id description _ ->
            model
                |> updateChecks (setEdit id (Editing description) model.checks)
                |> cmd
                |> cmdFocus (toString id)
                |> cmdSend

        CancelEditCheckbox id _ ->
            model
                |> updateChecks (setEdit id Set model.checks)
                |> cmdNone

        UpdateEditCheckbox id description ->
            model
                |> updateChecks (editCheckbox id description model.checks)
                |> cmdNone

        SaveEditCheckbox id ->
            model
                |> updateChecks (saveEdit id model.checks)
                |> cmd
                |> cmdSaveChecks
                |> cmdSendEditToDatabase id
                |> cmdSend

        DeleteCheckbox id description ->
            model
                |> updateChecks (deleteById id model.checks)
                |> cmd
                |> cmdSaveChecks
                |> cmdDeleteCheckboxRequest id
                |> cmdSend

        UpdateCreateCheckbox createDescription ->
            model
                |> updateCreate createDescription
                |> cmdNone

        CreateCheckbox ->
            let
                ( id, newCheckbox ) =
                    createCheckbox model

                create =
                    model.create
            in
            model
                |> updateChecks (model.checks ++ [ newCheckbox ])
                |> updateCreate ""
                |> cmd
                |> cmdSaveChecks
                |> cmdCreateCheckboxDatabase id create
                |> cmdFocus "create"
                |> cmdSend

        UpdateCheckboxDatabase _ (Ok checkbox) ->
            model
                |> updateChecks (updateById checkbox model.checks)
                |> cmd
                |> cmdSaveChecks
                |> cmdSend

        UpdateCheckboxDatabase checkbox (Err _) ->
            model
                |> updateFailedPosts (buildFailedCheckboxEdit checkbox model)
                |> updateError "Failed to change the checkbox in the cloud"
                |> cmd
                |> cmdSaveFailedPosts
                |> cmdSend

        GetAllCheckboxes (Ok checkboxes) ->
            model
                |> updateChecks checkboxes
                |> updateError ""
                |> updateLoadLoaded
                |> cmd
                |> cmdSaveChecks
                |> cmdSend

        GetAllCheckboxes (Err _) ->
            model
                |> updateError "Failed to load checkboxes"
                |> updateLoadLoaded
                |> cmdNone

        DeleteCheckboxDatabase id (Ok _) ->
            model
                |> updateChecks (deleteById id model.checks)
                |> cmdNone

        DeleteCheckboxDatabase id (Err _) ->
            model
                |> updateFailedPosts (addFailure (failedDelete id checklist.id) model)
                |> updateError "Unable to delete"
                |> cmd
                |> cmdSaveFailedPosts
                |> cmdSend

        CreateCheckboxDatabase id _ (Ok checkbox) ->
            model
                |> updateChecks (updateCheckbox id checkbox model.checks)
                |> cmd
                |> cmdSaveChecks
                |> cmdSend

        CreateCheckboxDatabase id description (Err err) ->
            model
                |> handleResponseError err id description
                |> cmd
                |> cmdSaveFailedPosts
                |> cmdSend

        _ ->
            checklistUpdate msg model


failedDelete : Int -> Int -> Failure
failedDelete checkId listId =
    CheckboxFailure (CheckUpdate Nothing False checkId listId DELETE)


failedCreate : Int -> Int -> String -> Failure
failedCreate checkId listId description =
    CheckboxFailure (CheckUpdate (Just description) False checkId listId CREATE)


handleResponseError : Http.Error -> Int -> String -> Model -> Model
handleResponseError err id description model =
    let
        failures =
            addFailure (failedCreate id (currentChecklistId model) description) model
    in
    case err of
        Http.BadStatus response ->
            case response.status.code of
                404 ->
                    model
                        |> updateError "Error adding checkboxes"

                401 ->
                    model
                        |> updateError "You do not have permission to edit that resource"

                _ ->
                    model
                        |> updateError (toString err)
                        |> updateFailedPosts failures

        _ ->
            model
                |> updateError (toString err)
                |> updateFailedPosts failures



-- Helpers


toggleChecked : Int -> List Checkbox -> List Checkbox
toggleChecked id checkboxes =
    let
        toggle cb =
            if cb.id == id then
                { cb | checked = not cb.checked }
            else
                cb
    in
    List.map toggle checkboxes


setEdit : Int -> Editing -> List Checkbox -> List Checkbox
setEdit id edit checkboxes =
    let
        findAndSetEdit cb =
            if cb.id == id then
                { cb | editing = edit }
            else
                cb
    in
    List.map findAndSetEdit checkboxes


editCheckbox : Int -> String -> List Checkbox -> List Checkbox
editCheckbox id newDescription checkboxes =
    let
        edit cb =
            if cb.id == id then
                { cb | editing = Editing newDescription, saved = Unsaved }
            else
                cb
    in
    List.map edit checkboxes


updateCheckbox : Int -> Checkbox -> List Checkbox -> List Checkbox
updateCheckbox id checkbox checkboxes =
    let
        edit cb =
            if cb.id == id then
                checkbox
            else
                cb
    in
    List.map edit checkboxes


saveEdit : Int -> List Checkbox -> List Checkbox
saveEdit id checkboxes =
    let
        edit cb =
            if cb.id == id then
                case cb.editing of
                    Editing description ->
                        { cb | editing = Set, description = description }

                    _ ->
                        cb
            else
                cb
    in
    List.map edit checkboxes


createCheckbox : Model -> ( Int, Checkbox )
createCheckbox model =
    let
        id =
            createUniqueCheckboxId (List.length model.checks * -1) model.checks

        newCheckbox =
            Checkbox model.create False id Unsaved Set Create
    in
    ( id, newCheckbox )


createUniqueCheckboxId : Int -> List Checkbox -> Int
createUniqueCheckboxId id checkboxes =
    case findById id checkboxes of
        Just _ ->
            createUniqueCheckboxId (id - 1) checkboxes

        Nothing ->
            id


buildFailedCheckboxEdit : Checkbox -> Model -> List Failure
buildFailedCheckboxEdit checkbox model =
    let
        description : String -> Maybe String
        description str =
            case str of
                "" ->
                    Nothing

                description ->
                    Just description

        checkboxDescription : Maybe String
        checkboxDescription =
            case findById checkbox.id model.checks of
                Just checkbox ->
                    description checkbox.description

                Nothing ->
                    Nothing

        failure =
            CheckboxFailure <|
                CheckUpdate
                    checkboxDescription
                    checkbox.checked
                    checkbox.id
                    (currentChecklistId model)
                    EDIT
    in
    addFailure failure model
