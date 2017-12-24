module ChecklistUpdate exposing (checklistUpdate)

import AuthenticationUpdate exposing (..)
import Checkbox exposing (focusElement)
import Checklist exposing (getEditString)
import Requests exposing (..)
import Types exposing (..)


checklistUpdate : Msg -> Model -> ( Model, Cmd Msg )
checklistUpdate msg model =
    case msg of
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

        _ ->
            authenticationUpdate msg model
