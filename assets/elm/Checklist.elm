module Checklist exposing (checklist)

import Dom exposing (..)
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Task exposing (..)
import Types exposing (..)


checklist : Model -> Html Msg
checklist model =
    div [] (List.map checklistView model.checklists)


checklistView checklist =
    div [] [ text checklist.title ]
