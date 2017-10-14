port module Ports exposing (..)

-- Out
port storeToken : (List String) -> Cmd msg
port getToken : () -> Cmd msg
port deleteSession : () -> Cmd msg
port loadMap : String -> Cmd msg

-- In
port tokenRecieved : (List String -> msg) -> Sub msg
