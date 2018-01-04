module Helpers exposing (..)

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
    { model | checklist = checklist }


updateListToLists : Model -> Model
updateListToLists model =
    let
        lists =
            updateById model.checklist model.checklists
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



-- Online


updateOnline : Model -> Model
updateOnline model =
    { model | online = Online }


updateOffline : Model -> Model
updateOffline model =
    { model | online = Offline }
