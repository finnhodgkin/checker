module AuthenticationUpdate exposing (authenticationUpdate)

import Checkbox exposing (focusElement)
import Requests exposing (..)
import Types exposing (..)


authenticationUpdate msg model =
    case msg of
        Logout ->
            { model | auth = Auth "" } ! []

        _ ->
            model ! []
