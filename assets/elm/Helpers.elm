module Helpers exposing (..)

import Json.Decode as JD exposing (..)
import Types exposing (..)


-- Generic


decodeStringToUnion : (String -> a) -> Decoder a
decodeStringToUnion typeCaseFunction =
    JD.string
        |> JD.andThen (\str -> JD.succeed (typeCaseFunction str))


findById : Int -> List { b | id : Int } -> Maybe { b | id : Int }
findById id list =
    List.head (List.filter (\item -> item.id == id) list)


deleteById : Int -> List { b | id : Int } -> List { b | id : Int }
deleteById id lists =
    List.filter (\list -> not <| list.id == id) lists



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
