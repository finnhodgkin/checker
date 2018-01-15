module Types exposing (..)

import Dom exposing (..)
import Http
import NoteTypes exposing (Note, NoteMsg)
import Time exposing (Time)


type alias Model =
    { checks : List Checkbox
    , error : String
    , create : String
    , auth : Auth
    , checklists : List Checklist
    , createChecklist : String
    , savedChecklist : Status
    , checkboxLoaded : Load
    , failedPosts : List Failure
    , online : Online
    , notes : List Note
    , noteRows : Int
    , createNote : Editing
    , view : View
    , checklistAnimation : Animate
    }


type View
    = NotesView
    | NoteView Int
    | ChecklistView
    | CheckboxView Checklist
    | AuthView


type Online
    = Online
    | Offline


type Failure
    = CheckboxFailure CheckUpdate
    | ChecklistFailure ChecklistUpdate


type alias CheckUpdate =
    { description : Maybe String
    , checked : Bool
    , id : Int
    , listId : Int
    , command : Request
    }


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
    | CreateCheckboxDatabase Int String (Result Http.Error Checkbox)
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
    | OnlineOffline Online
    | SendFailures Time
    | BadListDecode String
    | BadBoxDecode String
    | BadFailureDecode String
    | GetAllFailures (List Failure)
    | Notes NoteMsg
    | PreNotesView
    | SetNotesView
    | SetChecklistView
    | NoOp
