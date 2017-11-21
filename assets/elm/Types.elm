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
    }


type Msg
    = Check Int
    | GetAll (Result Http.Error (List Checkbox))
    | CheckDatabase (Result Http.Error Checkbox)
    | UpdateCreate String
    | CreateCheckbox
    | CreateCheckboxDatabase (Result Http.Error Checkbox)
    | FocusCreate (Result Dom.Error ())
    | NoOp
