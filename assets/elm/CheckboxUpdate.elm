module CheckboxUpdate exposing (checkboxUpdate)

import Checkbox exposing (focusElement)
import ChecklistUpdate exposing (checklistUpdate)
import DatabaseFailures exposing (..)
import Requests exposing (..)
import SaveToStorage exposing (..)
import Types exposing (..)


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


findCheckbox : Int -> List Checkbox -> Maybe Checkbox
findCheckbox id checkboxes =
    List.head (List.filter (\checkbox -> checkbox.id == id) checkboxes)


getFlippedChecked : Int -> List Checkbox -> Bool
getFlippedChecked id checkboxes =
    case findCheckbox id checkboxes of
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
    case findCheckbox id model.checks of
        Just checkbox ->
            case checkbox.editing of
                Editing description ->
                    updateCheckboxDatabase model.auth.token { checkbox | description = description } id

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
    case findCheckbox id checkboxes of
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


checkboxUpdate : Msg -> Model -> ( Model, Cmd Msg )
checkboxUpdate msg model =
    case msg of
        Check id ->
            let
                checkboxes =
                    toggleChecked id model.checks
            in
            { model | checks = checkboxes }
                ! [ save model.checklist.id checkboxes, checkToggle model.auth.token id (getFlippedChecked id model.checks) ]

        SetEditCheckbox id description set ->
            { model | checks = setEdit id (Editing description) model.checks } ! [ focusElement (toString id) ]

        CancelEditCheckbox id description ->
            { model | checks = setEdit id Set model.checks } ! []

        UpdateEditCheckbox id description ->
            { model | checks = editCheckbox id description model.checks } ! []

        SaveEditCheckbox id ->
            let
                checkboxes =
                    saveEdit id model.checks
            in
            { model | checks = checkboxes } ! [ save model.checklist.id checkboxes, sendEditToDatabase id model ]

        DeleteCheckbox id description ->
            let
                checkboxes =
                    deleteCheckbox id model.checks
            in
            { model | checks = checkboxes } ! [ save model.checklist.id checkboxes, deleteCheckboxRequest model.auth.token id ]

        UpdateCreateCheckbox createDescription ->
            { model | create = createDescription } ! []

        CreateCheckbox ->
            let
                ( id, newCheckbox ) =
                    createCheckbox model

                checkboxes =
                    model.checks ++ [ newCheckbox ]
            in
            { model | checks = checkboxes, create = "" }
                ! [ save model.checklist.id checkboxes, createCheckboxRequest model.auth.token id model.create False model.checklist.id, focusElement "create" ]

        UpdateCheckboxDatabase _ (Ok checkbox) ->
            let
                checkboxes =
                    updateFromDatabase checkbox model.checks
            in
            { model | checks = checkboxes } ! [ save model.checklist.id checkboxes ]

        UpdateCheckboxDatabase check (Err _) ->
            let
                description =
                    case check.description of
                        "" ->
                            Nothing

                        description ->
                            Just description

                checkboxDescription =
                    case findCheckbox check.id model.checks of
                        Just checkbox ->
                            Just checkbox.description

                        Nothing ->
                            Nothing

                failure =
                    CheckboxFailure (CheckUpdate checkboxDescription check.checked check.id model.checklist.id EDIT)

                failures =
                    addFailure failure model
            in
            { model
                | error = "Failed to change the checkbox in the cloud"
                , failedPosts = failures
            }
                ! [ saveFailures failures ]

        GetAllCheckboxes (Ok checkboxes) ->
            { model | checks = checkboxes, error = "", checkboxLoaded = Loaded } ! [ save model.checklist.id checkboxes ]

        GetAllCheckboxes (Err _) ->
            { model | error = "", checkboxLoaded = Loaded } ! []

        DeleteCheckboxDatabase id (Ok checkbox) ->
            let
                delete check =
                    not (check.id == id)
            in
            { model | checks = List.filter delete model.checks } ! []

        DeleteCheckboxDatabase id (Err err) ->
            let
                failure =
                    CheckboxFailure (CheckUpdate Nothing False id model.checklist.id DELETE)

                failures =
                    addFailure failure model
            in
            { model | error = "", failedPosts = failures } ! [ saveFailures failures ]

        CreateCheckboxDatabase id description (Ok checkbox) ->
            let
                checkboxes =
                    updateCheckbox id checkbox model.checks
            in
            { model | checks = checkboxes }
                ! [ save model.checklist.id checkboxes ]

        CreateCheckboxDatabase id description (Err err) ->
            let
                failure =
                    CheckboxFailure (CheckUpdate (Just description) False id model.checklist.id CREATE)

                failures =
                    addFailure failure model
            in
            { model | error = "Failed to add the checkbox to the cloud", failedPosts = failures } ! [ saveFailures failures ]

        _ ->
            checklistUpdate msg model
