module Page exposing (content)

import Checkbox exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Types exposing (..)


content : Model -> Html Msg
content model =
    Html.main_ [ class "mobile-container" ]
        [ checkboxes model
        ]
