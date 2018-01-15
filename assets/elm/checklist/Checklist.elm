module Checklist exposing (checklistView)

import Helpers exposing (animEnd)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Offline exposing (online)
import Svg exposing (path, svg)
import Svg.Attributes as SA exposing (d, fill, height, viewBox, width)
import Types exposing (..)


checklistView : Model -> Html Msg
checklistView model =
    let
        lists =
            case model.checklists of
                [] ->
                    div [ class "checkbox-error" ] [ text "No checklists found" ]

                _ ->
                    div [] (List.map checklistListItem model.checklists)

        ( headerAnim, footerAnim, mainAnim ) =
            case model.checklistAnimation of
                Create ->
                    ( " swipe_from_up", " swipe_from_down", " fade_in" )

                Delete ->
                    ( " swipe_up", " swipe_down", " fade_out" )

                NoAnimation ->
                    ( "", "", "" )
    in
    Html.main_
        []
        [ header [ class ("checklist-header" ++ headerAnim) ]
            [ section [ class "checklist-header__wrap" ]
                [ notesIcon
                , h1
                    [ class "checklist-header__title checketlist-header__title--centered" ]
                    [ text "Your checklists" ]
                , online model
                , Html.i [ class "material-icons logout", onClick Logout ] [ text "person_outline" ]
                ]
            ]
        , section (animEnd "fade-out" SetNotesView ++ [ class ("mobile-container" ++ mainAnim) ]) [ lists ]
        , createChecklist model.createChecklist footerAnim
        ]


notesIcon : Html Msg
notesIcon =
    let
        pathString =
            "M1528 1280h-248v248q29-10 41-22l185-185q12-12 22-41zm-280-128h288v"
                ++ "-896h-1280v1280h896v-288q0-40 28-68t68-28zm416-928v1024q0"
                ++ " 40-20 88t-48 76l-184 184q-28 28-76 48t-88 20h-1024q-40 0-6"
                ++ "8-28t-28-68v-1344q0-40 28-68t68-28h1344q40 0 68 28t28 68z"
    in
    svg [ onClick PreNotesView, SA.width "2rem", SA.height "2rem", viewBox "0 0 1792 1792" ] [ path [ d pathString, fill "#fff" ] [] ]


createChecklist : String -> String -> Html Msg
createChecklist create animation =
    let
        submit =
            if create == "" then
                Focus "create"
            else
                CreateChecklist
    in
    Html.form [ onSubmit submit, class ("create-checkbox" ++ animation) ]
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


checklistListItem : Checklist -> Html Msg
checklistListItem checklist =
    section [ class "checklist-item", onClick (SetList checklist) ] [ text checklist.title ]
