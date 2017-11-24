module Types exposing (..)

import Dom exposing (..)
import Http


type alias Model =
    { checks : List Checkbox
    , error : String
    , create : String
    , checklist : Checklist
    }


type alias Checkbox =
    { description : String
    , checked : Bool
    , id : Int
    , saved : Bool
    , editing : Bool
    , editString : String
    }


type alias Checklist =
    { title : String
    , id : Int
    , editing : Bool
    , editString : String
    }


type Msg
    = Check Int
    | GetAll (Result Http.Error (List Checkbox))
    | DeleteCheckbox Int String
    | DeleteCheckboxDatabase Int (Result Http.Error String)
    | SetEdit Int String Bool
    | CancelEdit Int String
    | UpdateCheckbox Int String
    | SaveCheckbox Int String
    | UpdateCheckboxDatabase (Result Http.Error Checkbox)
    | UpdateCreate String
    | CreateCheckbox
    | CreateCheckboxDatabase Int (Result Http.Error Checkbox)
    | FocusCreate (Result Dom.Error ())
    | EditChecklist
    | UpdateChecklist String
    | SetChecklist
    | ResetChecklist
    | UpdateChecklistDatabase (Result Http.Error Checklist)
    | Focus String
    | NoOp
