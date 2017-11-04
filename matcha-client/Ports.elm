port module Ports exposing (..)

-- Out
port storeToken : (List String) -> Cmd msg
port getToken : () -> Cmd msg
port deleteSession : () -> Cmd msg
port localize : (List Float) -> Cmd msg

-- In
port tokenRecieved : (List String -> msg) -> Sub msg
port newLocalisation : (List Float -> msg) -> Sub msg
