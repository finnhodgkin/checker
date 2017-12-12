module Types exposing (..)

import Dom exposing (..)
import Http


type alias Model =
    { checks : List Checkbox
    , error : String
    , create : String
    , checklist : Checklist
    , auth : Auth
    , checklists : List Checklist
    , createChecklist : String
    , savedChecklist : Status
    , checkboxLoaded : Load
    , failedPosts : List Failure
    }


type Failure
    = CheckboxFailure CheckUpdate
    | ChecklistFailure ChecklistUpdate


type alias CheckUpdate =
    { description : Maybe String, id : Int, listId : Int, command : Request }


type alias ChecklistUpdate =
    { title : Maybe String, id : Int, command : Request }


type Request
    = DELETE
    | CREATE
    | EDIT
    | SAVE


type Load
    = Loaded
    | Loading
    | Empty


type Status
    = Saved
    | Unsaved
    | Unloaded


type Editing
    = Editing String
    | Failed String
    | Set


type Animate
    = Create
    | Delete
    | NoAnimation


type alias Checkbox =
    { description : String
    , checked : Bool
    , id : Int
    , saved : Status
    , editing : Editing
    , animate : Animate
    }


type alias Checklist =
    { title : String
    , id : Int
    , editing : Editing
    }


type alias Auth =
    { token : String
    }


type Msg
    = Check Int
    | SetEditCheckbox Int String Bool
    | CancelEditCheckbox Int String
    | UpdateEditCheckbox Int String
    | SaveEditCheckbox Int
    | DeleteCheckbox Int String
    | UpdateCreateCheckbox String
    | CreateCheckbox
    | DeleteCheckboxDatabase Int (Result Http.Error String)
    | UpdateCheckboxDatabase Checkbox (Result Http.Error Checkbox)
    | GetAllCheckboxes (Result Http.Error (List Checkbox))
    | CreateCheckboxDatabase Int (Result Http.Error Checkbox)
    | FocusCreate (Result Dom.Error ())
    | UpdateCreateChecklist String
    | EditChecklist
    | CreateChecklist
    | UpdateChecklist String
    | DeleteChecklist
    | SetList Checklist
    | SetChecklist
    | ResetChecklist
    | CreateChecklistDatabase (Result Http.Error Checklist)
    | DeleteChecklistDatabase Int (Result Http.Error String)
    | ShowLists (Result Http.Error (List Checklist))
    | UpdateChecklistDatabase (Result Http.Error Checklist)
    | ClearAnimation Int
    | Focus String
    | Logout
    | NoOp
