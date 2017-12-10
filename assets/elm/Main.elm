module Main exposing (..)

import Checkbox exposing (focusElement)
import Checklist exposing (getEditString)
import Debug exposing (log)
import Dom exposing (..)
import Html exposing (Html)
import Page exposing (content)
import Requests exposing (..)
import Types exposing (..)


main : Program (Maybe String) Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


init : Maybe String -> ( Model, Cmd Msg )
init authToken =
    case authToken of
        Just token ->
            Model [] "" "" (Checklist "" 0 Set) (Auth token) [] "" Unloaded Empty [] ! [ getLists token ]

        Nothing ->
            Model []
                ""
                ""
                (Checklist "" 0 Set)
                (Auth "")
                []
                ""
                Unloaded
                Empty
                []
                ! []


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


isChecked : Int -> List Checkbox -> Bool
isChecked id checkboxes =
    case findCheckbox id checkboxes of
        Just checkbox ->
            not checkbox.checked

        Nothing ->
            False


setEdit : Int -> String -> Bool -> List Checkbox -> List Checkbox
setEdit id description setEdit checkboxes =
    let
        editing =
            if setEdit then
                Editing description
            else
                Set

        edit cb =
            if cb.id == id && cb.description == description then
                { cb | editing = editing }
            else
                cb
    in
    List.map edit checkboxes


saveEdit : Int -> String -> List Checkbox -> List Checkbox
saveEdit id editString checkboxes =
    let
        edit cb =
            if cb.id == id then
                { cb | editing = Set, description = editString }
            else
                cb
    in
    List.map edit checkboxes


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


updateCheckboxId : Int -> String -> Int -> List Checkbox -> List Checkbox
updateCheckboxId id description newId checkboxes =
    let
        edit cb =
            if cb.id == id && cb.description == description then
                { cb | id = newId, saved = Saved }
            else
                cb
    in
    List.map edit checkboxes


save : Int -> List Checkbox -> Bool -> List Checkbox
save id checkboxes saved =
    let
        save checkbox =
            if checkbox.id == id then
                { checkbox | saved = Saved }
            else
                checkbox
    in
    List.map save checkboxes


noOpArg : Int -> Cmd Msg
noOpArg int =
    Cmd.none


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Check toggleId ->
            { model | checks = toggleChecked toggleId model.checks }
                ! [ checkToggle model.auth.token toggleId (isChecked toggleId model.checks) ]

        UpdateCheckboxDatabase _ (Ok checkbox) ->
            { model | checks = updateFromDatabase checkbox model.checks } ! []

        UpdateCheckboxDatabase check (Err _) ->
            let
                description =
                    case check.description of
                        "" ->
                            Nothing

                        description ->
                            Just description

                failure =
                    CheckboxFailure (CheckUpdate description check.id model.checklist.id EDIT)
            in
            { model
                | error = "Failed to change the checkbox in the cloud"
                , failedPosts = addFailure failure model
            }
                ! []

        GetAll (Ok checkboxes) ->
            { model | checks = checkboxes, error = "", checkboxLoaded = Loaded } ! []

        GetAll (Err _) ->
            { model | error = "Failed to grab saved checkboxes", checkboxLoaded = Empty } ! []

        SetEdit id description set ->
            { model | checks = setEdit id description set model.checks } ! [ focusElement (toString id) ]

        CancelEdit id description ->
            { model | checks = setEdit id description False model.checks } ! []

        UpdateCheckbox id string ->
            { model | checks = editCheckbox id string model.checks } ! []

        SaveCheckbox id description ->
            let
                save =
                    case findCheckbox id model.checks of
                        Just checkbox ->
                            updateCheckbox model.auth.token { checkbox | description = description } id

                        Nothing ->
                            Cmd.none
            in
            { model | checks = saveEdit id description model.checks } ! [ save ]

        DeleteCheckbox id description ->
            { model | checks = save id model.checks False } ! [ deleteCheckboxRequest model.auth.token id ]

        DeleteCheckboxDatabase id (Ok checkbox) ->
            let
                delete check =
                    not (check.id == id)
            in
            { model | checks = List.filter delete model.checks } ! []

        DeleteCheckboxDatabase id (Err err) ->
            let
                failure =
                    CheckboxFailure (CheckUpdate Nothing id model.checklist.id DELETE)
            in
            { model | error = "", failedPosts = addFailure failure model } ! []

        UpdateCreate toCreate ->
            { model | create = toCreate } ! []

        CreateCheckbox ->
            let
                id =
                    List.length model.checks * -1

                checkbox =
                    Checkbox model.create False id Unsaved Set Create
            in
            { model | checks = model.checks ++ [ checkbox ], create = "" }
                ! [ createCheckboxRequest model.auth.token id model.create model.checklist.id, focusElement "create" ]

        CreateCheckboxDatabase id (Ok checkbox) ->
            { model
                | checks =
                    updateCheckboxId id checkbox.description checkbox.id model.checks
            }
                ! []

        CreateCheckboxDatabase id (Err err) ->
            let
                failure =
                    CheckboxFailure (CheckUpdate Nothing id model.checklist.id DELETE)
            in
            { model | error = "Failed to add the checkbox to the cloud" ++ toString err } ! []

        FocusCreate result ->
            case result of
                Err (Dom.NotFound id) ->
                    { model | error = "No '" ++ id ++ "' element found" } ! []

                Ok () ->
                    model ! []

        CreateChecklist ->
            { model | createChecklist = "", checklist = Checklist model.createChecklist 1 Set, savedChecklist = Unsaved } ! [ createChecklist model.auth.token model.createChecklist ]

        CreateChecklistDatabase (Ok checklist) ->
            { model
                | checklist =
                    checklist
                , checklists = model.checklists ++ [ checklist ]
                , savedChecklist = Saved
                , checkboxLoaded = Loaded
            }
                ! []

        CreateChecklistDatabase (Err err) ->
            { model | error = toString err } ! []

        UpdateCreateChecklist listName ->
            { model | createChecklist = listName } ! []

        SetList checklist ->
            { model | checklist = checklist, checkboxLoaded = Loading } ! [ fetchInitialData model.auth.token checklist.id ]

        EditChecklist ->
            let
                checklist : Checklist -> Checklist
                checklist list =
                    { list | editing = Editing list.title }
            in
            { model | checklist = checklist model.checklist } ! [ focusElement "title-input" ]

        UpdateChecklist newTitle ->
            let
                checklist list =
                    { list | editing = Editing newTitle }
            in
            { model | checklist = checklist model.checklist } ! []

        DeleteChecklist ->
            { model | checks = [] } ! [ deleteChecklist model ]

        DeleteChecklistDatabase id (Ok checklist) ->
            let
                delete check =
                    not (check.id == id)
            in
            { model | checklists = List.filter delete model.checklists, checklist = Checklist "" 0 Set } ! []

        DeleteChecklistDatabase id (Err err) ->
            { model | error = toString err } ! []

        ResetChecklist ->
            { model | checklist = Checklist "" 0 Set, checks = [], checkboxLoaded = Empty } ! []

        SetChecklist ->
            let
                edited list =
                    case getEditString model.checklist.editing of
                        Just str ->
                            { list | editing = Set, title = str }

                        Nothing ->
                            list

                update =
                    case getEditString model.checklist.editing of
                        Just _ ->
                            updateChecklist model.auth.token model.checklist

                        Nothing ->
                            Cmd.none
            in
            { model | checklist = edited model.checklist } ! [ update ]

        UpdateChecklistDatabase (Ok checklist) ->
            { model | checklist = checklist } ! []

        UpdateChecklistDatabase (Err err) ->
            { model | error = toString err, checkboxLoaded = Empty } ! []

        ShowLists (Ok checklists) ->
            { model | checklists = checklists, checkboxLoaded = Empty } ! []

        ShowLists (Err err) ->
            { model | error = toString err } ! []

        Logout ->
            { model | auth = Auth "" } ! []

        ClearAnimation id ->
            { model | checks = clearCheckboxAnimation id model.checks } ! []

        Focus elementId ->
            model ! [ focusElement elementId ]

        NoOp ->
            model ! []


clearCheckboxAnimation : Int -> List Checkbox -> List Checkbox
clearCheckboxAnimation id checkboxes =
    let
        edit cb =
            if cb.id == id then
                { cb | animate = NoAnimation }
            else
                cb
    in
    List.map edit checkboxes


addFailure : Failure -> Model -> List Failure
addFailure failure model =
    case failure of
        CheckboxFailure checkboxFailure ->
            addCheckboxFailure checkboxFailure model

        ChecklistFailure checklistFailure ->
            addChecklistFailure checklistFailure model


addCheckboxFailure : CheckUpdate -> Model -> List Failure
addCheckboxFailure update model =
    case update.command of
        DELETE ->
            checkboxFailedDelete update model

        CREATE ->
            List.filter
                (\post ->
                    case post of
                        CheckboxFailure checkbox ->
                            checkbox.id /= update.id

                        _ ->
                            True
                )
                model.failedPosts
                ++ [ CheckboxFailure update ]

        EDIT ->
            List.filter
                (\post ->
                    case post of
                        CheckboxFailure checkbox ->
                            (checkbox.id /= update.id)
                                || (checkbox.command /= EDIT)

                        _ ->
                            True
                )
                model.failedPosts
                ++ [ CheckboxFailure update ]

        SAVE ->
            model.failedPosts ++ [ CheckboxFailure update ]


addChecklistFailure : ChecklistUpdate -> Model -> List Failure
addChecklistFailure update model =
    case update.command of
        DELETE ->
            List.filter
                (\post ->
                    case post of
                        ChecklistFailure checklist ->
                            checklist.id /= update.id

                        _ ->
                            True
                )
                model.failedPosts
                ++ [ ChecklistFailure update ]

        CREATE ->
            List.filter
                (\post ->
                    case post of
                        ChecklistFailure checklist ->
                            checklist.id /= update.id && checklist.command /= CREATE

                        _ ->
                            True
                )
                model.failedPosts
                ++ [ ChecklistFailure update ]

        EDIT ->
            List.filter
                (\post ->
                    case post of
                        ChecklistFailure checklist ->
                            (checklist.id /= update.id)
                                && (checklist.command /= CREATE || checklist.command /= DELETE)

                        _ ->
                            True
                )
                model.failedPosts
                ++ [ ChecklistFailure update ]

        SAVE ->
            List.map (\post -> post) model.failedPosts


checkboxFailedDelete update model =
    List.filter
        (\post ->
            case post of
                CheckboxFailure checkbox ->
                    checkbox.id /= update.id

                _ ->
                    True
        )
        model.failedPosts
        ++ [ CheckboxFailure update ]


view : Model -> Html Msg
view model =
    content model
