port module Ports exposing (..)

-- Out
port storeToken : (List String) -> Cmd msg
port getToken : () -> Cmd msg
port deleteSession : () -> Cmd msg
port localize : () -> Cmd msg

-- In
port tokenRecieved : (List String -> msg) -> Sub msg
