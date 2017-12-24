module PeriodicSend exposing (..)

import Requests exposing (..)
import Types exposing (..)


sendFailures : Model -> List (Cmd Msg)
sendFailures model =
    let
        eachFailure failure =
            case failure of
                CheckboxFailure update ->
                    let
                        description =
                            Maybe.withDefault "" update.description
                    in
                    case update.command of
                        DELETE ->
                            deleteCheckboxRequest
                                model.auth.token
                                update.id

                        CREATE ->
                            createCheckboxRequest
                                model.auth.token
                                update.id
                                description
                                update.listId

                        EDIT ->
                            checkboxUpdateBoth model.auth.token
                                (Checkbox
                                    description
                                    update.checked
                                    update.id
                                    Saved
                                    Set
                                    NoAnimation
                                )

                        SAVE ->
                            Cmd.none

                ChecklistFailure update ->
                    Cmd.none
    in
    List.map eachFailure model.failedPosts
