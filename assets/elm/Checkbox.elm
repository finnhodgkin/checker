module Checkbox exposing (checkboxes, focusElement)

import Dom exposing (..)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Task exposing (..)
import Types exposing (..)


checkboxes : Model -> Html Msg
checkboxes model =
    div [ class "checkboxes" ]
        [ div [] (List.map checkbox (List.sortBy .description model.checks))
        , createCheckbox model.create
        , checkboxError model.error
        ]


checkIcon : Checkbox -> Html Msg
checkIcon checkbox =
    if not checkbox.saved then
        Html.i [ class "material-icons button--rounded button--grey button--right-pad" ] [ text "cloud_off" ]
    else if checkbox.checked then
        Html.i [ class "material-icons button--rounded button--right-pad" ] [ text "done" ]
    else
        Html.i [ class "material-icons button--rounded button--empty button--right-pad" ] [ text "close" ]


savedClass : Bool -> String
savedClass saved =
    if saved then
        "saved"
    else
        "unsaved"


updateOnSubmit : Checkbox -> Attribute Msg
updateOnSubmit checkbox =
    if checkbox.editString == "" then
        onSubmit (DeleteCheckbox checkbox.id checkbox.description)
    else
        onSubmit (SaveCheckbox checkbox.id checkbox.editString)


editing : Checkbox -> Html Msg
editing checkbox =
    if checkbox.editing then
        Html.form [ updateOnSubmit checkbox, class "checkbox--form" ]
            [ input
                [ class "checkbox--text checkbox--input"
                , id (toString checkbox.id)
                , type_ "text"
                , value checkbox.editString
                , onInput (UpdateCheckbox checkbox.id)
                , autocomplete False
                ]
                []
            ]
    else
        div [ class "checkbox--text" ] [ text checkbox.description ]


editingButton : Checkbox -> Html Msg
editingButton checkbox =
    if checkbox.editing then
        Html.i [ onClick (SaveCheckbox checkbox.id checkbox.editString), class "material-icons button--rounded button--pad" ] [ text "done" ]
    else
        Html.i [ onClick (SetEdit checkbox.id checkbox.description True), class "material-icons button--rounded button--pad" ] [ text "edit" ]


rightButton : Checkbox -> Html Msg
rightButton checkbox =
    if checkbox.editing then
        Html.i [ onClick (CancelEdit checkbox.id checkbox.description), class "material-icons button--rounded" ] [ text "close" ]
    else
        Html.i [ onClick (DeleteCheckbox checkbox.id checkbox.description), class "material-icons button--rounded" ] [ text "delete_forever" ]


checkbox : Checkbox -> Html Msg
checkbox checkbox =
    div [ class ("checkbox " ++ savedClass checkbox.saved) ]
        [ label [ class "checkbox-checker" ]
            [ checkIcon checkbox
            , input
                [ type_ "checkbox"
                , checked checkbox.checked
                , onClick (Check checkbox.id)
                , class "visually-hidden"
                ]
                []
            , span [ class "visually-hidden" ] [ text "check off item" ]
            ]
        , editing checkbox
        , editingButton checkbox
        , rightButton checkbox
        ]


createCheckbox : String -> Html Msg
createCheckbox create =
    let
        submit =
            if create == "" then
                NoOp
            else
                CreateCheckbox
    in
    Html.form [ onSubmit submit, class "create-checkbox" ]
        [ input
            [ type_ "text"
            , onInput UpdateCreate
            , id "create"
            , class "create-checkbox__input"
            , value create
            , autocomplete False
            ]
            []
        , Html.i [ onClick submit, class "material-icons button--rounded button--left-pad" ] [ text "add" ]
        , label [ class "visually-hidden" ]
            [ text "Add a checkbox" ]
        ]


checkboxError : String -> Html Msg
checkboxError message =
    div [ HA.class "checkbox-error" ] [ text message ]


focusElement : String -> Cmd Msg
focusElement elementId =
    Dom.focus elementId |> Task.attempt FocusCreate
