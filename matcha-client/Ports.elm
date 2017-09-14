port module Ports exposing (..)

-- Out
port storeToken : String -> Cmd msg
port getToken : () -> Cmd msg

-- In
port tokenRecieved : (String -> msg) -> Sub msg
