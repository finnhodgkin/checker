module Checkbox exposing (checkboxes, focusElement)

import Dom exposing (..)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (oneOf, succeed)
import Task exposing (..)
import Types exposing (..)


checkboxes : Model -> Html Msg
checkboxes model =
    let
        checkboxes =
            if List.length model.checks == 0 then
                div [ class "checkbox-error" ] [ text "No checkboxes found" ]
            else
                div [] (List.map checkbox (List.sortBy .description model.checks))
    in
    div [ class "checkboxes" ]
        [ checkboxes
        , checkboxError model.error
        ]


checkIcon : Checkbox -> Html Msg
checkIcon checkbox =
    case checkbox.saved of
        Saved ->
            if checkbox.checked then
                div [ class "checkbox__control" ]
                    [ Html.i [ class "material-icons button-background button--on-animation" ]
                        [ text "close" ]
                    , Html.i
                        [ class "material-icons button--rounded button--right-pad" ]
                        [ text "done" ]
                    ]
            else
                Html.i [ class "material-icons button--rounded button--empty button--right-pad" ] [ text "close" ]

        _ ->
            Html.i [ class "material-icons button--rounded button--grey button--right-pad" ] [ text "cloud_off" ]


savedClass : Status -> String
savedClass saved =
    case saved of
        Saved ->
            "saved"

        _ ->
            "unsaved"


saveOrDelete : Checkbox -> String -> Msg
saveOrDelete checkbox editString =
    case editString of
        "" ->
            DeleteCheckbox checkbox.id checkbox.description

        string ->
            SaveCheckbox checkbox.id string


editing : Checkbox -> Html Msg
editing checkbox =
    case checkbox.editing of
        Editing string ->
            Html.form [ onSubmit (saveOrDelete checkbox string), class "checkbox--form" ]
                [ input
                    [ class "checkbox--text checkbox--input"
                    , id (toString checkbox.id)
                    , type_ "text"
                    , value string
                    , onInput (UpdateCheckbox checkbox.id)
                    , autocomplete False
                    ]
                    []
                ]

        _ ->
            div [ class "checkbox--text" ] [ text checkbox.description ]


captureAnimEnd : Int -> List (Attribute Msg)
captureAnimEnd id =
    List.map (\ae -> on ae (Json.Decode.succeed (ClearAnimation id)))
        [ "webkitAnimationEnd", "oanimationend", "msAnimationEnd", "animationend" ]


buttonAnimation : Animate -> String
buttonAnimation animate =
    case animate of
        Create ->
            " button_checkbox"

        _ ->
            ""


editingButton : Checkbox -> Html Msg
editingButton checkbox =
    case checkbox.editing of
        Editing string ->
            Html.i [ onClick (saveOrDelete checkbox string), class "material-icons button--rounded button--pad" ] [ text "done" ]

        _ ->
            Html.i (captureAnimEnd checkbox.id ++ [ onClick (SetEdit checkbox.id checkbox.description True), class ("material-icons button--rounded button--pad" ++ buttonAnimation checkbox.animate) ]) [ text "edit" ]


rightButton : Checkbox -> Html Msg
rightButton checkbox =
    case checkbox.editing of
        Editing _ ->
            Html.i [ onClick (CancelEdit checkbox.id checkbox.description), class "material-icons button--rounded" ] [ text "close" ]

        _ ->
            Html.i (captureAnimEnd checkbox.id ++ [ onClick (DeleteCheckbox checkbox.id checkbox.description), class ("material-icons button--rounded" ++ buttonAnimation checkbox.animate) ]) [ text "delete_forever" ]


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


checkboxError : String -> Html Msg
checkboxError message =
    div [ HA.class "checkbox-error" ] [ text message ]


focusElement : String -> Cmd Msg
focusElement elementId =
    Dom.focus elementId |> Task.attempt FocusCreate
