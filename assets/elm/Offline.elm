module Offline exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Types exposing (..)


online : Model -> Html Msg
online model =
    case model.online of
        Online ->
            Html.i [ class "material-icons online-offline" ] [ text "cloud" ]

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
                    { model | online = Online } ! []

                Offline ->
                    { model | online = Offline } ! []

        _ ->
            model ! []
