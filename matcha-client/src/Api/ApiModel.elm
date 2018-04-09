module Api.ApiModel exposing (..)


type alias ApiResponse a =
    { status : Bool
    , message : Maybe String
    , data : a
    }
