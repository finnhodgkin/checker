port module Main exposing (..)

import CheckboxUpdate exposing (..)
import CommandHelpers exposing (..)
import Dom exposing (..)
import Helpers exposing (..)
import Html exposing (Html)
import Json.Encode exposing (Value)
import Offline exposing (decodeOnlineOffline)
import Page exposing (content)
import Requests exposing (..)
import SaveToStorage exposing (..)
import Types exposing (..)


main : Program (Maybe String) Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


port isOnline : (Value -> msg) -> Sub msg


subscriptions : a -> Sub Msg
subscriptions model =
    Sub.batch
        [ isOnline decodeOnlineOffline
        , getChecklists decodeListChecklist
        , sendStoredCheckboxes decodeListCheckbox
        , getFailures decodeListFailures
        ]


init : Maybe String -> ( Model, Cmd Msg )
init authToken =
    let
        model token =
            Model [] "" "" (Checklist "" 0 Set) (Auth token) [] "" Unloaded Empty [] Online []
    in
    case authToken of
        Just token ->
            model token ! [ getLists token ]

        Nothing ->
            model "" ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            cmdNone model

        ClearAnimation id ->
            model
                |> updateChecks (clearCheckboxAnimation id model.checks)
                |> cmdNone

        Focus elementId ->
            model
                |> cmd
                |> cmdFocus elementId
                |> cmdSend

        FocusCreate (Ok ()) ->
            cmdNone model

        FocusCreate (Err (Dom.NotFound id)) ->
            model
                |> updateError ("No '" ++ id ++ "' element found")
                |> cmdNone

        BadListDecode error ->
            model
                |> updateError error
                |> cmdNone

        BadBoxDecode error ->
            model
                |> updateError error
                |> cmdNone

        BadFailureDecode error ->
            model
                |> updateError error
                |> cmdNone

        GetAllFailures failures ->
            model
                |> updateFailedPosts failures
                |> cmdNone

        _ ->
            checkboxUpdate msg model


clearCheckboxAnimation : Int -> List Checkbox -> List Checkbox
clearCheckboxAnimation id checkboxes =
    let
        edit cb =
            if cb.id == id then
                { cb | animate = NoAnimation }
            else
                cb
    in
    List.map edit checkboxes


view : Model -> Html Msg
view model =
    content model
