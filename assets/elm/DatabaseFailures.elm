module DatabaseFailures exposing (addFailure)

import Types exposing (..)


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
            checkboxEdit update model

        SAVE ->
            model.failedPosts ++ [ CheckboxFailure update ]


checkboxEdit : CheckUpdate -> Model -> List Failure
checkboxEdit update model =
    if update.id <= 0 then
        List.map
            (\failure ->
                case failure of
                    CheckboxFailure checkbox ->
                        if (checkbox.id == update.id) && checkbox.command == CREATE then
                            CheckboxFailure { update | command = CREATE }
                        else
                            CheckboxFailure checkbox

                    failure ->
                        failure
            )
            model.failedPosts
    else
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


checkboxFailedDelete : CheckUpdate -> Model -> List Failure
checkboxFailedDelete update model =
    let
        filter =
            List.filter
                (\post ->
                    case post of
                        CheckboxFailure checkbox ->
                            checkbox.id /= update.id

                        _ ->
                            True
                )
                model.failedPosts
    in
    if update.id <= 0 then
        filter
    else
        filter ++ [ CheckboxFailure update ]
