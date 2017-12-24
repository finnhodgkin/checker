port module Main exposing (..)

import Checkbox exposing (focusElement)
import CheckboxUpdate exposing (..)
import Dom exposing (..)
import Html exposing (Html)
import Json.Encode exposing (Value)
import Offline exposing (decodeOnlineOffline)
import Page exposing (content)
import Requests exposing (..)
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
        ]


init : Maybe String -> ( Model, Cmd Msg )
init authToken =
    case authToken of
        Just token ->
            Model [] "" "" (Checklist "" 0 Set) (Auth token) [] "" Unloaded Empty [] Online ! [ getLists token ]

        Nothing ->
            Model []
                ""
                ""
                (Checklist "" 0 Set)
                (Auth "")
                []
                ""
                Unloaded
                Empty
                []
                Online
                ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        ClearAnimation id ->
            { model | checks = clearCheckboxAnimation id model.checks } ! []

        Focus elementId ->
            model ! [ focusElement elementId ]

        FocusCreate result ->
            case result of
                Err (Dom.NotFound id) ->
                    { model | error = "No '" ++ id ++ "' element found" } ! []

                Ok () ->
                    model ! []

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
