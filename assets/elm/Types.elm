module Types exposing (..)

import Dom exposing (..)
import Http


type alias Model =
    { checks : List Checkbox
    , error : String
    , create : String
    , saved : List Saved
    }


type alias Saved =
    { id : Int
    , saved : Bool
    }


type alias Checkbox =
    { description : String
    , checked : Bool
    , id : Int
    }


type Msg
    = Check Int
    | GetAll (Result Http.Error (List Checkbox))
    | CheckDatabase (Result Http.Error Checkbox)
    | DeleteCheckbox Int String
    | DeleteCheckboxDatabase Int (Result Http.Error String)
    | UpdateCheckbox Int String
    | UpdateCreate String
    | CreateCheckbox
    | CreateCheckboxDatabase Int (Result Http.Error Checkbox)
    | FocusCreate (Result Dom.Error ())
    | NoOp
