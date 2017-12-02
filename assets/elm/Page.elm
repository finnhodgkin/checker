module Page exposing (content)

import Authentication exposing (authenticateView)
import Checkbox exposing (..)
import Checklist exposing (checklists)
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
    Html.i [ class "material-icons back-button", onClick ResetChecklist ] [ text "chevron_left" ]


deleteTitle : Html Msg
deleteTitle =
    Html.i [ class "material-icons back-button", onMouseDown DeleteChecklist ] [ text "delete_forever" ]


content : Model -> Html Msg
content model =
    if model.auth.token == "" then
        authenticateView model
    else if model.checklist.id == 0 then
        checklists model
    else
        Html.main_ []
            [ header [ class "checklist-header" ]
                [ section [ class "checklist-header__wrap" ]
                    [ backButton
                    , inputTitle model.checklist
                    , editTitle model.checklist
                    , deleteTitle
                    ]
                ]
            , section [ class "mobile-container" ] [ checkboxes model ]
            ]
