module Page exposing (content)

import Authentication exposing (authenticateView)
import Checkbox exposing (..)
import Checklist exposing (checklists, getEditString)
import Helpers exposing (isJust)
import Html exposing (..)
import Html.Attributes exposing (autocomplete, class, for, id, type_, value)
import Html.Events exposing (..)
import Notes exposing (notes)
import Types exposing (..)


content : Model -> Html Msg
content model =
    if model.auth.token == "" then
        authenticateView model
    else if isJust model.currentNote then
        div [ class "notes-container" ] [ notes model ]
    else if model.checklist.id == 0 then
        Html.main_ []
            [ checklists model
            , div [ class "mobile-container" ] [ notes model ]
            ]
    else
        Html.main_ []
            [ checkListHeader model.checklist
            , div [ class "overflow-none" ] [ section [ class "mobile-container animate-right" ] [ checkboxes model ] ]
            , createCheckbox model.create
            ]


checkListHeader : Checklist -> Html Msg
checkListHeader checklist =
    header [ class "checklist-header" ]
        [ section [ class "checklist-header__wrap" ]
            [ backButton
            , checklistTitle checklist
            , checklistEditButton checklist
            , checklistDeleteButton
            ]
        ]


backButton : Html Msg
backButton =
    Html.i
        [ class "material-icons back-button fade_in", onClick ResetChecklist ]
        [ text "chevron_left" ]


checklistTitle : Checklist -> Html Msg
checklistTitle checklist =
    case getEditString checklist.editing of
        Just str ->
            Html.form [ class "checklist-header__form", onSubmit SetChecklist ]
                [ input
                    [ type_ "text"
                    , id "title-input"
                    , onInput UpdateChecklist
                    , onBlur SetChecklist
                    , class "checklist-header__input"
                    , value str
                    ]
                    []
                ]

        Nothing ->
            h1 [ class "checklist-header__title" ] [ text checklist.title ]


checklistEditButton : Checklist -> Html Msg
checklistEditButton checklist =
    case getEditString checklist.editing of
        Just str ->
            div [] []

        Nothing ->
            Html.i
                [ class "material-icons checklist-header__button fade_in"
                , onClick EditChecklist
                ]
                [ text "edit" ]


checklistDeleteButton : Html Msg
checklistDeleteButton =
    Html.i
        [ class "material-icons back-button fade_in"
        , onMouseDown DeleteChecklist
        ]
        [ text "delete_forever" ]


createCheckbox : String -> Html Msg
createCheckbox create =
    let
        submit =
            if create == "" then
                Focus "create-checkbox"
            else
                CreateCheckbox
    in
    Html.form [ onSubmit submit, class "create-checkbox" ]
        (createCheckboxInput create ++ [ submitButton submit ])


createCheckboxInput : String -> List (Html Msg)
createCheckboxInput create =
    [ label [ for "create-checkbox", class "visually-hidden" ]
        [ text "Add a checkbox" ]
    , input
        [ type_ "text"
        , onInput UpdateCreateCheckbox
        , id "create-checkbox"
        , class "create-checkbox__input"
        , value create
        , autocomplete False
        ]
        []
    ]


submitButton : Msg -> Html Msg
submitButton submit =
    Html.i
        [ onClick submit
        , class "material-icons button--rounded button--left-pad"
        ]
        [ text "add" ]
