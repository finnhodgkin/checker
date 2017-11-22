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
    Model [] "" "" [] ! [ fetchInitialData ]


toggleChecked id checkboxes =
    let
        toggle cb =
            if cb.id == id then
                { cb | checked = not cb.checked }
            else
                cb
    in
    List.map toggle checkboxes


isChecked id checkboxes =
    case List.head (List.filter (\checkbox -> checkbox.id == id) checkboxes) of
        Just checkbox ->
            not checkbox.checked

        Nothing ->
            False


editCheckbox id newDescription checkboxes =
    let
        edit cb =
            if cb.id == id then
                { cb | description = newDescription }
            else
                cb
    in
    List.map edit checkboxes


updateCheckboxId id description newId checkboxes =
    let
        edit cb =
            if cb.id == id && cb.description == description then
                { cb | id = newId }
            else
                cb
    in
    List.map edit checkboxes


unsave id savedCheckbox =
    let
        unSave saved =
            if saved.id == id then
                { saved | saved = False }
            else
                saved
    in
    List.map unSave savedCheckbox


buildSaved checkboxes =
    List.map (\checkbox -> { id = checkbox.id, saved = True }) checkboxes


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Check toggleId ->
            { model | checks = toggleChecked toggleId model.checks, saved = unsave toggleId model.saved }
                ! [ checkToggle toggleId (isChecked toggleId model.checks) ]

        CheckDatabase (Ok checkboxes) ->
            model ! []

        CheckDatabase (Err _) ->
            { model | error = "The checkbox in the cloud failed to update" } ! []

        GetAll (Ok checkboxes) ->
            { model | checks = checkboxes, saved = buildSaved checkboxes, error = "" } ! []

        GetAll (Err _) ->
            { model | error = "Failed to grab saved checkboxes" } ! []

        UpdateCheckbox id string ->
            { model | checks = editCheckbox id string model.checks } ! []

        DeleteCheckbox id description ->
            let
                delete check =
                    not (check.id == id && check.description == description)
            in
            { model | checks = List.filter delete model.checks } ! [ deleteCheckboxRequest id ]

        DeleteCheckboxDatabase id (Ok checkbox) ->
            { model | error = "Trimmed from the cloud" } ! []

        DeleteCheckboxDatabase id (Err _) ->
            { model | error = "Failed to remove checkbox from the cloud" } ! []

        UpdateCreate toCreate ->
            { model | create = toCreate } ! []

        CreateCheckbox ->
            let
                id =
                    List.length model.checks

                checkbox =
                    Checkbox model.create False id
            in
            { model | checks = model.checks ++ [ checkbox ], saved = model.saved ++ [ Saved id False ], create = "" }
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
