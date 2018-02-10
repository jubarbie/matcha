module Api.ApiModel exposing (..)

type alias ApiResponse a =
    { status : String
    , message : Maybe String
    , data : a
    }
