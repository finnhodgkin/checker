module Page exposing (content)

import Checkbox exposing (..)
import Html exposing (..)
import Types exposing (..)


content : Model -> Html Msg
content model =
    Html.main_ []
        [ checkboxes model
        ]
