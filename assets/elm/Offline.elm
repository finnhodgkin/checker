module Offline exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import PeriodicSend exposing (..)
import SaveToStorage exposing (clearSavedFailures)
import Types exposing (..)


online : Model -> Html Msg
online model =
    case model.online of
        Online ->
            Html.i [ class "material-icons online-offline" ] [ text "cloud_queue" ]

        Offline ->
            Html.i [ class "material-icons online-offline" ] [ text "cloud_off" ]


decodeOnlineOffline : Decode.Value -> Msg
decodeOnlineOffline isOnline =
    case Decode.decodeValue Decode.string isOnline of
        Ok "online" ->
            OnlineOffline Online

        Ok "offline" ->
            OnlineOffline Offline

        _ ->
            NoOp


offlineUpdate : Msg -> Model -> ( Model, Cmd Msg )
offlineUpdate msg model =
    case msg of
        OnlineOffline online ->
            case online of
                Online ->
                    { model | failedPosts = [], online = Online } ! (sendFailures model ++ [ clearSavedFailures ])

                Offline ->
                    { model | online = Offline } ! []

        _ ->
            model ! [ Cmd.none ]
