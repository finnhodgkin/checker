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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Check toggleId ->
            let
                toggle cb =
                    if cb.id == toggleId then
                        { cb | checked = not cb.checked }
                    else
                        cb

                isChecked cb =
                    case List.head (List.filter (\checkbox -> checkbox.id == toggleId) cb) of
                        Just checkbox ->
                            not checkbox.checked

                        Nothing ->
                            False
            in
            { model | checks = List.map toggle model.checks }
                ! [ checkToggle toggleId (isChecked model.checks) ]

        CheckDatabase (Ok checkboxes) ->
            model ! []

        CheckDatabase (Err _) ->
            { model | error = "The checkbox in the cloud failed to update" } ! []

        GetAll (Ok checkboxes) ->
            { model | checks = checkboxes, error = "" } ! []

        GetAll (Err _) ->
            { model | error = "Failed to grab saved checkboxes" } ! []

        UpdateCreate toCreate ->
            { model | create = toCreate } ! []

        CreateCheckbox ->
            let
                checkbox =
                    Checkbox model.create False 0
            in
            { model | checks = model.checks ++ [ checkbox ], create = "" }
                ! [ createCheckboxRequest model.create, focusCreate ]

        CreateCheckboxDatabase (Ok checkbox) ->
            { model | error = "Successfully added checkbox to the cloud " } ! []

        CreateCheckboxDatabase (Err _) ->
            { model | error = "Failed to add the checkbox to the cloud " } ! []

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
