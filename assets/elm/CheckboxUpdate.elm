module CheckboxUpdate exposing (checkboxUpdate)

import Checkbox exposing (focusElement)
import ChecklistUpdate exposing (checklistUpdate)
import DatabaseFailures exposing (..)
import Helpers exposing (..)
import Http
import Requests exposing (..)
import SaveToStorage exposing (..)
import Types exposing (..)


-- Update


checkboxUpdate : Msg -> Model -> ( Model, Cmd Msg )
checkboxUpdate msg model =
    case msg of
        Check id ->
            model |> check_ id

        SetEditCheckbox id description set ->
            model |> setEditCheckbox_ id description

        CancelEditCheckbox id description ->
            model |> cancelEditCheckbox_ id description

        UpdateEditCheckbox id description ->
            model |> updateEditCheckbox_ id description

        SaveEditCheckbox id ->
            model |> saveEditCheckbox_ id

        DeleteCheckbox id description ->
            model |> deleteCheckbox_ id description

        UpdateCreateCheckbox createDescription ->
            model |> updateCreateCheckbox_ createDescription

        CreateCheckbox ->
            model |> createCheckbox_

        UpdateCheckboxDatabase _ (Ok checkbox) ->
            model |> updateCheckboxDatabase_ checkbox

        UpdateCheckboxDatabase checkbox (Err _) ->
            model |> updateCheckboxDatabaseErr_ checkbox

        GetAllCheckboxes (Ok checkboxes) ->
            model |> getAllCheckboxes_ checkboxes

        GetAllCheckboxes (Err _) ->
            model |> getAllCheckboxesErr_

        DeleteCheckboxDatabase id (Ok _) ->
            model |> deleteCheckboxDatabase_ id

        DeleteCheckboxDatabase id (Err _) ->
            model |> deleteCheckboxDatabaseErr_ id

        CreateCheckboxDatabase id _ (Ok checkbox) ->
            model |> createCheckboxDatabase_ id checkbox

        CreateCheckboxDatabase id description (Err err) ->
            model |> createCheckboxDatabaseErr_ id description err

        _ ->
            checklistUpdate msg model



-- Update functions


check_ : Int -> Model -> ( Model, Cmd Msg )
check_ id model =
    let
        checkboxes =
            toggleChecked id model.checks
    in
    updateChecks checkboxes model
        ! [ save model.checklist.id checkboxes
          , checkToggle model.auth.token id (getFlippedChecked id model.checks)
          ]


setEditCheckbox_ : Int -> String -> Model -> ( Model, Cmd Msg )
setEditCheckbox_ id description model =
    updateChecks (setEdit id (Editing description) model.checks) model
        ! [ focusElement (toString id) ]


cancelEditCheckbox_ : Int -> String -> Model -> ( Model, Cmd Msg )
cancelEditCheckbox_ id description model =
    updateChecks (setEdit id Set model.checks) model ! []


updateEditCheckbox_ : Int -> String -> Model -> ( Model, Cmd Msg )
updateEditCheckbox_ id description model =
    updateChecks (editCheckbox id description model.checks) model ! []


saveEditCheckbox_ : Int -> Model -> ( Model, Cmd Msg )
saveEditCheckbox_ id model =
    let
        checkboxes =
            saveEdit id model.checks
    in
    updateChecks checkboxes model
        ! [ save model.checklist.id checkboxes, sendEditToDatabase id model ]


deleteCheckbox_ : Int -> String -> Model -> ( Model, Cmd Msg )
deleteCheckbox_ id description model =
    let
        checkboxes =
            deleteCheckbox id model.checks
    in
    updateChecks checkboxes model
        ! [ save model.checklist.id checkboxes
          , deleteCheckboxRequest model.auth.token id
          ]


updateCreateCheckbox_ : String -> Model -> ( Model, Cmd Msg )
updateCreateCheckbox_ create model =
    updateCreate create model ! []


createCheckbox_ : Model -> ( Model, Cmd Msg )
createCheckbox_ model =
    let
        ( id, newCheckbox ) =
            createCheckbox model

        ( token, create, checkId ) =
            ( model.auth.token, model.create, model.checklist.id )

        checkboxes =
            model.checks ++ [ newCheckbox ]
    in
    (model
        |> updateChecks checkboxes
        |> updateCreate ""
    )
        ! [ save model.checklist.id checkboxes
          , createCheckboxRequest token id create False checkId
          , focusElement "create"
          ]


updateCheckboxDatabase_ : Checkbox -> Model -> ( Model, Cmd Msg )
updateCheckboxDatabase_ checkbox model =
    let
        checkboxes =
            updateFromDatabase checkbox model.checks
    in
    updateChecks checkboxes model ! [ save model.checklist.id checkboxes ]


updateCheckboxDatabaseErr_ : Checkbox -> Model -> ( Model, Cmd Msg )
updateCheckboxDatabaseErr_ checkbox model =
    let
        failures =
            buildFailedCheckboxEdit checkbox model
    in
    (model
        |> updateFailedPosts failures
        |> updateError "Failed to change the checkbox in the cloud"
    )
        ! [ saveFailures failures ]


getAllCheckboxes_ : List Checkbox -> Model -> ( Model, Cmd Msg )
getAllCheckboxes_ checkboxes model =
    (model
        |> updateChecks checkboxes
        |> updateError ""
        |> updateLoadLoaded
    )
        ! [ save model.checklist.id checkboxes ]


getAllCheckboxesErr_ : Model -> ( Model, Cmd Msg )
getAllCheckboxesErr_ model =
    (model
        |> updateError "Failed to load checkboxes"
        |> updateLoadLoaded
    )
        ! []


deleteCheckboxDatabase_ : Int -> Model -> ( Model, Cmd Msg )
deleteCheckboxDatabase_ id model =
    let
        checkboxes =
            List.filter (\check -> not (check.id == id)) model.checks
    in
    updateChecks checkboxes model ! []


deleteCheckboxDatabaseErr_ : Int -> Model -> ( Model, Cmd Msg )
deleteCheckboxDatabaseErr_ id model =
    let
        failure =
            CheckboxFailure (CheckUpdate Nothing False id model.checklist.id DELETE)

        failures =
            addFailure failure model
    in
    (model
        |> updateFailedPosts failures
        |> updateError "Unable to delete"
    )
        ! [ saveFailures failures ]


createCheckboxDatabase_ : Int -> Checkbox -> Model -> ( Model, Cmd Msg )
createCheckboxDatabase_ id checkbox model =
    let
        checkboxes =
            updateCheckbox id checkbox model.checks
    in
    (model
        |> updateChecks checkboxes
    )
        ! [ save model.checklist.id checkboxes ]


createCheckboxDatabaseErr_ : Int -> String -> Http.Error -> Model -> ( Model, Cmd Msg )
createCheckboxDatabaseErr_ id description err model =
    let
        failure =
            CheckboxFailure (CheckUpdate (Just description) False id model.checklist.id CREATE)

        failures =
            addFailure failure model

        newModel =
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
    in
    newModel ! [ saveFailures failures ]



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


getFlippedChecked : Int -> List Checkbox -> Bool
getFlippedChecked id checkboxes =
    case findById id checkboxes of
        Just checkbox ->
            not checkbox.checked

        Nothing ->
            False


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


sendEditToDatabase : Int -> Model -> Cmd Msg
sendEditToDatabase id model =
    case findById id model.checks of
        Just checkbox ->
            case checkbox.editing of
                Editing description ->
                    updateCheckboxDatabase
                        model.auth.token
                        { checkbox | description = description }
                        id

                _ ->
                    Cmd.none

        Nothing ->
            Cmd.none


deleteCheckbox : Int -> List Checkbox -> List Checkbox
deleteCheckbox id checkboxes =
    List.filter (\cb -> cb.id /= id) checkboxes


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


updateFromDatabase : Checkbox -> List Checkbox -> List Checkbox
updateFromDatabase checkbox checkboxes =
    let
        update check =
            if check.id == checkbox.id then
                checkbox
            else
                check
    in
    List.map update checkboxes


save : Int -> List Checkbox -> Cmd Msg
save id checkboxes =
    setCheckboxes (encodeCheckboxes id checkboxes)


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
                    model.checklist.id
                    EDIT
    in
    addFailure failure model
