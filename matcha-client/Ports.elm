port module Ports exposing (..)

type alias ImagePortData =
    { contents : String
    , filename : String
    }

-- Out
port storeToken : (List String) -> Cmd msg
port getToken : () -> Cmd msg
port deleteSession : () -> Cmd msg
port localize : (List Float) -> Cmd msg
port fileSelected : String -> Cmd msg

-- In
port tokenRecieved : (List String -> msg) -> Sub msg
port newLocalisation : (List Float -> msg) -> Sub msg
port fileContentRead : (ImagePortData -> msg) -> Sub msg
