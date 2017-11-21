module Checkbox exposing (checkbox, createCheckbox, focusCreate)

import Dom exposing (..)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Task exposing (..)
import Types exposing (..)


checkbox : Checkbox -> Html Msg
checkbox checkbox =
    label []
        [ input
            [ type_ "checkbox"
            , checked checkbox.checked
            , onClick (Check checkbox.id)
            ]
            []
        , text checkbox.description
        ]


createCheckbox : String -> Html Msg
createCheckbox create =
    Html.form [ onSubmit CreateCheckbox ]
        [ label []
            [ input
                [ type_ "text"
                , onInput UpdateCreate
                , id "create"
                ]
                [ text create ]
            ]
        ]


focusCreate : Cmd Msg
focusCreate =
    Dom.focus "create" |> Task.attempt FocusCreate
