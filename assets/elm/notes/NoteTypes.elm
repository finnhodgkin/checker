module NoteTypes exposing (..)


type NoteMsg
    = UpdateNote String
    | UpdateTitle String
    | SetNote Int
    | NewValues String Int
    | ClearNote
    | CreateNote
    | UpdateCreateNote String
    | SetNoteEdit


type alias Note =
    { note : String
    , title : String
    , id : Int
    }
