module Checklist exposing (checklists, getEditString)

import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Maybe exposing (..)
import Offline exposing (online)
import Types exposing (..)


getEditString : Editing -> Maybe String
getEditString editing =
    case editing of
        Editing str ->
            Just str

        Set ->
            Nothing


checklists : Model -> Html Msg
checklists model =
    let
        lists =
            case model.checklists of
                [] ->
                    div [ class "checkbox-error" ] [ text "No checklists found" ]

                _ ->
                    div [] (List.map checklistView model.checklists)
    in
    div []
        [ header [ class "checklist-header" ]
            [ section [ class "checklist-header__wrap" ]
                [ online model
                , h1
                    [ class "checklist-header__title checketlist-header__title--centered" ]
                    [ text "Your checklists" ]
                , Html.i [ class "material-icons logout", onClick Logout ] [ text "person_outline" ]
                ]
            ]
        , section [ class "mobile-container" ] [ lists ]
        , createChecklist model.createChecklist
        ]


createChecklist : String -> Html Msg
createChecklist create =
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
        , Html.i [ onClick submit, class "material-icons button--rounded button--left-pad create-item__button" ] [ text "add" ]
        , label [ class "visually-hidden" ]
            [ text "Add a checkbox" ]
        ]


checklistView : Checklist -> Html Msg
checklistView checklist =
    section [ class "checklist-item", onClick (SetList checklist) ] [ text checklist.title ]