module Main exposing (..)

import Checkbox exposing (focusElement)
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
            Model [] "" "" (Checklist "" 0 False "") (Auth token) [] "" Unloaded ! [ getLists token ]

        Nothing ->
            Model []
                ""
                ""
                (Checklist "" 0 False "")
                (Auth "")
                []
                ""
                Unloaded
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
        edit cb =
            if cb.id == id && cb.description == description then
                { cb | editing = setEdit, editString = description }
            else
                cb
    in
    List.map edit checkboxes


saveEdit : Int -> String -> List Checkbox -> List Checkbox
saveEdit id editString checkboxes =
    let
        edit cb =
            if cb.id == id then
                { cb | editing = False, editString = "", description = editString }
            else
                cb
    in
    List.map edit checkboxes


editCheckbox : Int -> String -> List Checkbox -> List Checkbox
editCheckbox id newDescription checkboxes =
    let
        edit cb =
            if cb.id == id then
                { cb | editString = newDescription, saved = False }
            else
                cb
    in
    List.map edit checkboxes


updateCheckboxId : Int -> String -> Int -> List Checkbox -> List Checkbox
updateCheckboxId id description newId checkboxes =
    let
        edit cb =
            if cb.id == id && cb.description == description then
                { cb | id = newId, saved = True }
            else
                cb
    in
    List.map edit checkboxes


save : Int -> List Checkbox -> Bool -> List Checkbox
save id checkboxes saved =
    let
        save unSaved =
            if unSaved.id == id then
                { unSaved | saved = saved }
            else
                unSaved
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

        UpdateCheckboxDatabase (Ok checkbox) ->
            { model | checks = updateFromDatabase checkbox model.checks } ! []

        UpdateCheckboxDatabase (Err _) ->
            { model | error = "Failed to change the checkbox in the cloud" } ! []

        GetAll (Ok checkboxes) ->
            { model | checks = checkboxes, error = "" } ! []

        GetAll (Err _) ->
            { model | error = "Failed to grab saved checkboxes" } ! []

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
                            updateCheckbox model.auth.token { checkbox | description = description }

                        Nothing ->
                            noOpArg
            in
            { model | checks = saveEdit id description model.checks } ! [ save id ]

        DeleteCheckbox id description ->
            { model | checks = save id model.checks False } ! [ deleteCheckboxRequest model.auth.token id ]

        DeleteCheckboxDatabase id (Ok checkbox) ->
            let
                delete check =
                    not (check.id == id)
            in
            { model | checks = List.filter delete model.checks } ! []

        DeleteCheckboxDatabase id (Err test) ->
            let
                hi =
                    log (toString test)
            in
            { model | error = "" } ! []

        UpdateCreate toCreate ->
            { model | create = toCreate } ! []

        CreateCheckbox ->
            let
                id =
                    List.length model.checks * -1

                checkbox =
                    Checkbox model.create False id False False ""
            in
            { model | checks = model.checks ++ [ checkbox ], create = "" }
                ! [ createCheckboxRequest model.auth.token id model.create model.checklist.id, focusElement "create" ]

        CreateCheckboxDatabase id (Ok checkbox) ->
            { model
                | checks =
                    updateCheckboxId id checkbox.description checkbox.id model.checks
            }
                ! []

        CreateCheckboxDatabase id (Err _) ->
            { model | error = "Failed to add the checkbox to the cloud" } ! []

        FocusCreate result ->
            case result of
                Err (Dom.NotFound id) ->
                    { model | error = "No '" ++ id ++ "' element found" } ! []

                Ok () ->
                    model ! []

        CreateChecklist ->
            { model | createChecklist = "", checklist = Checklist model.createChecklist 1 False "", savedChecklist = Unsaved } ! [ createChecklist model.auth.token model.createChecklist ]

        CreateChecklistDatabase (Ok checklist) ->
            { model
                | checklist =
                    checklist
                , checklists = model.checklists ++ [ checklist ]
                , savedChecklist = Saved
            }
                ! []

        CreateChecklistDatabase (Err err) ->
            { model | error = toString err } ! []

        UpdateCreateChecklist listName ->
            { model | createChecklist = listName } ! []

        SetList checklist ->
            { model | checklist = checklist } ! [ fetchInitialData model.auth.token checklist.id ]

        EditChecklist ->
            let
                checklist : Checklist -> Checklist
                checklist list =
                    { list | editing = True, editString = list.title }
            in
            { model | checklist = checklist model.checklist } ! [ focusElement "title-input" ]

        UpdateChecklist newTitle ->
            let
                checklist list =
                    { list | editString = newTitle }
            in
            { model | checklist = checklist model.checklist } ! []

        DeleteChecklist ->
            model ! [ deleteChecklist model ]

        DeleteChecklistDatabase id (Ok checklist) ->
            let
                delete check =
                    not (check.id == id)
            in
            { model | checklists = List.filter delete model.checklists, checklist = Checklist "" 0 False "" } ! []

        DeleteChecklistDatabase id (Err err) ->
            { model | error = toString err } ! []

        ResetChecklist ->
            { model | checklist = Checklist "" 0 False "", checks = [] } ! []

        SetChecklist ->
            let
                checklist list =
                    { list | editing = False, editString = "", title = model.checklist.editString }

                update =
                    if model.checklist.editString /= "" then
                        updateChecklist model.auth.token model.checklist
                    else
                        Cmd.none
            in
            { model | checklist = checklist model.checklist } ! [ update ]

        UpdateChecklistDatabase (Ok checklist) ->
            { model | checklist = checklist } ! []

        UpdateChecklistDatabase (Err err) ->
            { model | error = toString err } ! []

        ShowLists (Ok checklists) ->
            { model | checklists = checklists } ! []

        ShowLists (Err err) ->
            { model | error = toString err } ! []

        Logout ->
            { model | auth = Auth "" } ! []

        Focus elementId ->
            model ! [ focusElement elementId ]

        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    content model
