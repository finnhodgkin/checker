module PeriodicSend exposing (..)

import Requests exposing (..)
import Types exposing (..)


periodicSendUpdate : Msg -> Model -> ( Model, Cmd Msg )
periodicSendUpdate msg model =
    case msg of
        SendFailures _ ->
            case model.online of
                Online ->
                    { model | failedPosts = [] } ! sendFailures model

                Offline ->
                    model ! []

        _ ->
            model ! []


sendFailures : Model -> List (Cmd Msg)
sendFailures model =
    let
        eachFailure failure =
            case failure of
                CheckboxFailure update ->
                    case update.command of
                        DELETE ->
                            deleteCheckboxRequest model.auth.token update.id

                        CREATE ->
                            createCheckboxRequest model.auth.token update.id (Maybe.withDefault "" update.description) update.listId

                        EDIT ->
                            Cmd.none

                        SAVE ->
                            Cmd.none

                ChecklistFailure update ->
                    Cmd.none
    in
    List.map eachFailure model.failedPosts
