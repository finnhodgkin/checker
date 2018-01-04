module Offline exposing (..)

import CommandHelpers exposing (..)
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode exposing (Value, decodeValue, string)
import NotesUpdate exposing (..)
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


decodeOnlineOffline : Value -> Msg
decodeOnlineOffline isOnline =
    case decodeValue string isOnline of
        Ok "online" ->
            OnlineOffline Online

        Ok "offline" ->
            OnlineOffline Offline

        _ ->
            NoOp


offlineUpdate : Msg -> Model -> ( Model, Cmd Msg )
offlineUpdate msg model =
    case msg of
        OnlineOffline Online ->
            model
                |> updateFailedPosts []
                |> updateOnline
                |> cmd
                |> cmdSendFailures
                |> cmdSend

        OnlineOffline Offline ->
            model
                |> updateOffline
                |> cmdNone

        Notes noteMsg ->
            notesUpdate noteMsg model

        _ ->
            cmdNone model
