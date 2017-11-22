module Main exposing (..)

import Checkbox exposing (focusCreate)
import Dom exposing (..)
import Html exposing (Html)
import Page exposing (content)
import Requests exposing (..)
import Types exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


init : ( Model, Cmd Msg )
init =
    Model [] "" "" ! [ fetchInitialData ]


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


editCheckbox : Int -> String -> List Checkbox -> List Checkbox
editCheckbox id newDescription checkboxes =
    let
        edit cb =
            if cb.id == id then
                { cb | description = newDescription, saved = False }
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


noOpArg : Checkbox -> Int -> Cmd Msg
noOpArg checkbox int =
    Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Check toggleId ->
            { model | checks = toggleChecked toggleId model.checks }
                ! [ checkToggle toggleId (isChecked toggleId model.checks) ]

        CheckDatabase (Ok checkbox) ->
            { model | checks = save checkbox.id model.checks True } ! []

        CheckDatabase (Err _) ->
            { model | error = "Failed to update in the cloud" } ! []

        GetAll (Ok checkboxes) ->
            { model | checks = checkboxes, error = "" } ! []

        GetAll (Err _) ->
            { model | error = "Failed to grab saved checkboxes" } ! []

        UpdateCheckbox id string ->
            { model | checks = editCheckbox id string model.checks } ! []

        SaveCheckbox id ->
            let
                save =
                    case findCheckbox id model.checks of
                        Just checkbox ->
                            updateCheckbox checkbox

                        Nothing ->
                            noOpArg (Checkbox "" False 1 False)
            in
            model ! [ save id ]

        UpdateCheckboxDatabase (Ok checkbox) ->
            { model | checks = save checkbox.id model.checks True } ! []

        UpdateCheckboxDatabase (Err _) ->
            { model | error = "Failed to change the checkbox in the cloud" } ! []

        DeleteCheckbox id description ->
            { model | checks = save id model.checks False } ! [ deleteCheckboxRequest id ]

        DeleteCheckboxDatabase id (Ok checkbox) ->
            let
                delete check =
                    not (check.id == id)
            in
            { model | checks = List.filter delete model.checks, error = "Trimmed from the cloud" } ! []

        DeleteCheckboxDatabase id (Err _) ->
            { model | error = "Failed to remove checkbox from the cloud" } ! []

        UpdateCreate toCreate ->
            { model | create = toCreate } ! []

        CreateCheckbox ->
            let
                id =
                    List.length model.checks

                checkbox =
                    Checkbox model.create False id False
            in
            { model | checks = model.checks ++ [ checkbox ], create = "" }
                ! [ createCheckboxRequest id model.create, focusCreate ]

        CreateCheckboxDatabase id (Ok checkbox) ->
            { model
                | error = "Successfully added checkbox to the cloud"
                , checks = updateCheckboxId id checkbox.description checkbox.id model.checks
            }
                ! []

        CreateCheckboxDatabase id (Err _) ->
            { model | error = "Failed to add the checkbox to the cloud" } ! []

        FocusCreate result ->
            case result of
                Err (Dom.NotFound id) ->
                    { model | error = "No create element found" } ! []

                Ok () ->
                    model ! []

        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    content model
