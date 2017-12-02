module Checklist exposing (checklists)

import Dom exposing (..)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Task exposing (..)
import Types exposing (..)


checklists : Model -> Html Msg
checklists model =
    div []
        [ header [ class "checklist-header" ]
            [ section [ class "checklist-header__wrap" ]
                [ h1
                    [ class "checklist-header__title checketlist-header__title--centered" ]
                    [ text "Your checklists" ]
                , Html.i [ class "material-icons logout", onClick Logout ] [ text "person_outline" ]
                ]
            ]
        , section [ class "mobile-container" ] [ div [] (List.map checklistView model.checklists) ]
        , createCheckbox model.createChecklist
        ]


createCheckbox : String -> Html Msg
createCheckbox create =
    let
        submit =
            if create == "" then
                Focus "create"
            else
                CreateChecklist
    in
    Html.form [ onSubmit submit, class "create-checkbox" ]
        [ input
            [ type_ "text"
            , onInput UpdateCreateChecklist
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


checklistView checklist =
    button [ onClick (SetList checklist) ] [ text checklist.title ]
