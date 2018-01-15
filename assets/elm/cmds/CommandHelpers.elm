module CommandHelpers exposing (..)

import Checkbox exposing (focusElement)
import Helpers exposing (currentChecklistId, findById)
import PeriodicSend exposing (sendFailures)
import Requests exposing (..)
import SaveToStorage exposing (clearSavedFailures, encodeListChecklist, fetchCheckboxesFromLS, save, saveFailures, setLists)
import Types exposing (..)


cmdNone : Model -> ( Model, Cmd Msg )
cmdNone model =
    model ! []


cmd : Model -> ( Model, List (Cmd Msg) )
cmd model =
    ( model, [] )


cmdSend : ( Model, List (Cmd Msg) ) -> ( Model, Cmd Msg )
cmdSend modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    model ! cmd


cmdCreateChecklist : String -> ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdCreateChecklist title modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ [ createChecklist model.auth.token title ] )


cmdSetLists : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdSetLists modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ [ setLists (encodeListChecklist model.checklists) ] )


cmdFetchFromBoth : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdFetchFromBoth modelCmd =
    let
        ( model, cmd ) =
            modelCmd

        listId =
            currentChecklistId model
    in
    ( model
    , cmd ++ [ fetchCheckboxesFromLS listId, fetchInitialData model.auth.token listId ]
    )


cmdFocus : String -> ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdFocus string modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ [ focusElement string ] )


cmdDeleteList : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdDeleteList modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ [ deleteChecklist model ] )



-- Checkboxes


cmdSaveChecks : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdSaveChecks modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ [ save (currentChecklistId model) model.checks ] )


cmdCheckToggle : Int -> ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdCheckToggle id modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ [ checkToggle model.auth.token id (getChecked id model.checks) ] )


cmdSendEditToDatabase : Int -> ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdSendEditToDatabase id modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ [ sendEditToDatabase id model ] )


cmdCreateCheckboxDatabase : Int -> String -> ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdCreateCheckboxDatabase id description modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ [ createCheckboxRequest model.auth.token id description False (currentChecklistId model) ] )


cmdDeleteCheckboxRequest : Int -> ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdDeleteCheckboxRequest id modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ [ deleteCheckboxRequest model.auth.token id ] )


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


getChecked : Int -> List Checkbox -> Bool
getChecked id checkboxes =
    case findById id checkboxes of
        Just checkbox ->
            checkbox.checked

        Nothing ->
            False



-- Failed posts


cmdSaveFailedPosts : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdSaveFailedPosts modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ [ saveFailures model.failedPosts ] )


cmdSendFailures : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
cmdSendFailures modelCmd =
    let
        ( model, cmd ) =
            modelCmd
    in
    ( model, cmd ++ sendFailures model ++ [ clearSavedFailures ] )
