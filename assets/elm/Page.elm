module Page exposing (content)

import Checkbox exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, id, type_, value)
import Html.Events exposing (..)
import Types exposing (..)


editTitle : Checklist -> Html Msg
editTitle checklist =
    if checklist.editing then
        div [] []
    else
        Html.i [ class "material-icons checklist-header__button", onClick EditChecklist ] [ text "edit" ]


inputTitle : Checklist -> Html Msg
inputTitle checklist =
    if checklist.editing then
        Html.form [ class "checklist-header__form", onSubmit SetChecklist ]
            [ input [ type_ "text", id "title-input", onInput UpdateChecklist, onBlur SetChecklist, class "checklist-header__input", value checklist.editString ] []
            ]
    else
        h1 [ class "checklist-header__title" ] [ text checklist.title ]


backButton : Html Msg
backButton =
    Html.i [ class "material-icons back-button" ] [ text "chevron_left" ]


content : Model -> Html Msg
content model =
    Html.main_ []
        [ header [ class "checklist-header" ]
            [ section [ class "checklist-header__wrap" ]
                [ backButton
                , inputTitle model.checklist
                , editTitle model.checklist
                ]
            ]
        , section [ class "mobile-container" ] [ checkboxes model ]
        ]
