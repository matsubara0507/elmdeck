port module Port.FS exposing (..)


type alias File =
    { path : String
    , body : String
    }


port readFile : (File -> msg) -> Sub msg


port writeFileHook : (Maybe String -> msg) -> Sub msg


port writeFile : File -> Cmd msg
