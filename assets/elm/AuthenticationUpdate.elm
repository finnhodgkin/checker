port module AuthenticationUpdate exposing (authenticationUpdate)

import Offline exposing (offlineUpdate)
import Types exposing (..)


port logOut : Bool -> Cmd msg


authenticationUpdate : Msg -> Model -> ( Model, Cmd Msg )
authenticationUpdate msg model =
    case msg of
        Logout ->
            { model | auth = Auth "" } ! [ logOut True ]

        _ ->
            offlineUpdate msg model
