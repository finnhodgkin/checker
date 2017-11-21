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
        [ div [] (List.map checkbox (List.sortBy .description model.checks))
        , createCheckbox model.create
        , checkboxError model.error
        ]


checkIcon : Bool -> Html Msg
checkIcon checked =
    if checked then
        div [ class "checkbox-checker__icon" ] []
    else
        div [ class "checkbox-checker__icon--off" ] []


checkbox : Checkbox -> Html Msg
checkbox checkbox =
    label [ class "checkbox-checker" ]
        [ checkIcon checkbox.checked
        , span [ class "checkbox-checker__label" ] [ text checkbox.description ]
        , input
            [ type_ "checkbox"
            , checked checkbox.checked
            , onClick (Check checkbox.id)
            , class "visually-hidden"
            ]
            []
        ]


createCheckbox : String -> Html Msg
createCheckbox create =
    Html.form [ onSubmit CreateCheckbox, class "checkbox-create" ]
        [ label [ class "checkbox-create__label" ]
            [ input
                [ type_ "text"
                , onInput UpdateCreate
                , id "create"
                , class "checkbox-create__input"
                ]
                [ text create ]
            , text "Add a checkbox"
            ]
        ]


checkboxError : String -> Html Msg
checkboxError message =
    div [ HA.class "checkbox-error" ] [ text message ]


focusCreate : Cmd Msg
focusCreate =
    Dom.focus "create" |> Task.attempt FocusCreate
