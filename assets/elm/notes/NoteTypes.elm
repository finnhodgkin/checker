module NoteTypes exposing (..)


type NoteMsg
    = UpdateCurrentNote String
    | SetCurrentNote Int


type alias Note =
    { note : String
    , title : String
    , id : Int
    }
