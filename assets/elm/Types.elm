module Types exposing (..)

import Dom exposing (..)
import Http


type alias Model =
    { checks : List Checkbox
    , error : String
    , create : String
    }


type alias Checkbox =
    { description : String
    , checked : Bool
    , id : Int
    , saved : Bool
    }


type Msg
    = Check Int
    | GetAll (Result Http.Error (List Checkbox))
    | CheckDatabase (Result Http.Error Checkbox)
    | DeleteCheckbox Int String
    | DeleteCheckboxDatabase Int (Result Http.Error String)
    | UpdateCheckbox Int String
    | SaveCheckbox Int
    | UpdateCheckboxDatabase (Result Http.Error Checkbox)
    | UpdateCreate String
    | CreateCheckbox
    | CreateCheckboxDatabase Int (Result Http.Error Checkbox)
    | FocusCreate (Result Dom.Error ())
    | NoOp
