module Helpers exposing (..)

import Html exposing (Attribute)
import Html.Events exposing (on)
import Json.Decode as JD exposing (..)
import Types exposing (..)


-- Generic


decodeStringToUnion : (String -> a) -> Decoder a
decodeStringToUnion typeCaseFunction =
    JD.string
        |> JD.andThen (\str -> JD.succeed (typeCaseFunction str))


findById : Int -> List { a | id : Int } -> Maybe { a | id : Int }
findById id list =
    List.head (List.filter (\item -> item.id == id) list)


deleteById : Int -> List { a | id : Int } -> List { a | id : Int }
deleteById id list =
    List.filter (\item -> not <| item.id == id) list


updateById : { a | id : Int } -> List { a | id : Int } -> List { a | id : Int }
updateById newItem list =
    let
        update item =
            if item.id == newItem.id then
                newItem
            else
                item
    in
    List.map update list


createUniqueId : Int -> List { a | id : Int } -> Int
createUniqueId id list =
    case findById id list of
        Just _ ->
            createUniqueId (id - 1) list

        Nothing ->
            id


isJust : Maybe a -> Bool
isJust mayb =
    case mayb of
        Just _ ->
            True

        Nothing ->
            False


currentChecklistMaybe : Model -> Maybe Checklist
currentChecklistMaybe model =
    case model.view of
        CheckboxView checklist ->
            Just checklist

        _ ->
            Nothing


currentChecklist : Model -> Checklist
currentChecklist model =
    Maybe.withDefault (Checklist "" 0 Set) (currentChecklistMaybe model)


currentChecklistId : Model -> Int
currentChecklistId model =
    Maybe.withDefault 0 <| Maybe.map (\check -> check.id) (currentChecklistMaybe model)


animEnd : String -> Msg -> List (Attribute Msg)
animEnd name msg =
    let
        decoder =
            field "animationName" string
                |> JD.andThen
                    (\str ->
                        if str == name then
                            succeed msg
                        else
                            fail ""
                    )
    in
    List.map (\ae -> on ae decoder)
        [ "webkitAnimationEnd", "oanimationend", "msAnimationEnd", "animationend" ]



-- Views


updateCheckboxView : Checklist -> Model -> Model
updateCheckboxView checklist model =
    { model | view = CheckboxView checklist }


updateChecklistView : Model -> Model
updateChecklistView model =
    { model | view = ChecklistView }


updateNoteView : Int -> Model -> Model
updateNoteView id model =
    { model | view = NoteView id }


updateNotesView : Model -> Model
updateNotesView model =
    { model | view = NotesView }


updateAuthView : Model -> Model
updateAuthView model =
    { model | view = AuthView }



-- Checkboxes


updateChecks : List Checkbox -> Model -> Model
updateChecks checkboxes model =
    { model | checks = checkboxes }


updateCreate : String -> Model -> Model
updateCreate create model =
    { model | create = create }


updateLoadLoaded : Model -> Model
updateLoadLoaded model =
    { model | checkboxLoaded = Loaded }


updateLoadEmpty : Model -> Model
updateLoadEmpty model =
    { model | checkboxLoaded = Empty }


updateLoadLoading : Model -> Model
updateLoadLoading model =
    { model | checkboxLoaded = Loading }


updateCheckboxLoaded : Load -> Model -> Model
updateCheckboxLoaded load model =
    { model | checkboxLoaded = load }



-- Failures


updateFailedPosts : List Failure -> Model -> Model
updateFailedPosts failures model =
    { model | failedPosts = failures }



-- Auth


setNoAuth : Model -> Model
setNoAuth model =
    { model | auth = Auth "" }



-- Error


updateError : String -> Model -> Model
updateError error model =
    { model | error = error }



-- Checklists


updateList : Checklist -> Model -> Model
updateList checklist model =
    { model | view = CheckboxView checklist }


updateListToLists : Model -> Model
updateListToLists model =
    let
        list =
            Maybe.withDefault (Checklist "" 0 Set) (currentChecklistMaybe model)

        lists =
            updateById list model.checklists
    in
    { model | checklists = lists }


updateCreateList : String -> Model -> Model
updateCreateList title model =
    { model | createChecklist = title }


updateLists : List Checklist -> Model -> Model
updateLists checklists model =
    { model | checklists = checklists }


updateListStatus : Status -> Model -> Model
updateListStatus status model =
    { model | savedChecklist = status }


startListEdit : Checklist -> Checklist
startListEdit list =
    { list | editing = Editing list.title }


updateListEditing : String -> Checklist -> Checklist
updateListEditing editString list =
    { list | editing = Editing editString }


updateChecklistAnimCreate : Model -> Model
updateChecklistAnimCreate model =
    { model | checklistAnimation = Create }


updateChecklistAnimDelete : Model -> Model
updateChecklistAnimDelete model =
    { model | checklistAnimation = Delete }


updateChecklistAnimNone : Model -> Model
updateChecklistAnimNone model =
    { model | checklistAnimation = NoAnimation }



-- Online


updateOnline : Model -> Model
updateOnline model =
    { model | online = Online }


updateOffline : Model -> Model
updateOffline model =
    { model | online = Offline }
