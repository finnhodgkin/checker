module Checkbox exposing (checkboxes, focusCreate)

import Dom exposing (..)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Task exposing (..)
import Types exposing (..)


checkboxes : Model -> Html Msg
checkboxes model =
    div [ class "checkboxes" ]
        [ div [] (List.map checkbox (List.sortBy .id model.checks))
        , createCheckbox model.create
        , checkboxError model.error
        ]


checkIcon : Bool -> Html Msg
checkIcon checked =
    if checked then
        Html.i [ class "material-icons" ] [ text "check_box" ]
    else
        Html.i [ class "material-icons" ] [ text "check_box_outline_blank" ]


savedClass : Bool -> String
savedClass saved =
    if saved then
        "saved"
    else
        "unsaved"


updateOnSubmit : Checkbox -> List (Attribute Msg)
updateOnSubmit checkbox =
    if checkbox.description == "" then
        [ onSubmit (DeleteCheckbox checkbox.id checkbox.description) ]
    else
        [ onSubmit (SaveCheckbox checkbox.id) ]


checkbox : Checkbox -> Html Msg
checkbox checkbox =
    div [ class (savedClass checkbox.saved) ]
        [ label [ class "checkbox-checker" ]
            [ checkIcon checkbox.checked
            , input
                [ type_ "checkbox"
                , checked checkbox.checked
                , onClick (Check checkbox.id)
                , class "visually-hidden"
                ]
                []
            , Html.form (updateOnSubmit checkbox)
                [ input
                    [ class "checkbox-checker__label"
                    , type_ "text"
                    , value checkbox.description
                    , onInput (UpdateCheckbox checkbox.id)
                    , autocomplete False
                    ]
                    []
                ]
            , button [ onClick (DeleteCheckbox checkbox.id checkbox.description) ] [ text "Delete" ]
            ]
        ]


createCheckbox : String -> Html Msg
createCheckbox create =
    let
        submit =
            if create == "" then
                onSubmit NoOp
            else
                onSubmit CreateCheckbox
    in
    Html.form [ submit, class "checkbox-create" ]
        [ label [ class "checkbox-create__label" ]
            [ input
                [ type_ "text"
                , onInput UpdateCreate
                , id "create"
                , class "checkbox-create__input"
                , value create
                , autocomplete False
                ]
                []
            , text "Add a checkbox"
            ]
        ]


checkboxError : String -> Html Msg
checkboxError message =
    div [ HA.class "checkbox-error" ] [ text message ]


focusCreate : Cmd Msg
focusCreate =
    Dom.focus "create" |> Task.attempt FocusCreate
