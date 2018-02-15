module Api.ApiRequest exposing (..)

import Http
import Json.Decode exposing (Decoder)
import Api.ApiModel exposing (ApiResponse)
import Api.ApiDecoder exposing (decodeApiResponse)

authHeader : String -> Http.Header
authHeader token =
    Http.header "Authorization" ("Bearer " ++ token)


apiGetRequest : Maybe (Decoder a) -> String -> String -> Http.Request (ApiResponse (Maybe a))
apiGetRequest decoder token url =
    Http.request
        { method = "GET"
        , headers = [ authHeader token ]
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson (decodeApiResponse decoder)
        , timeout = Nothing
        , withCredentials = False
        }

apiPostRequest : Maybe (Decoder a) -> String -> String -> Http.Body -> Http.Request (ApiResponse (Maybe a))
apiPostRequest decoder token url body =
    Http.request
        { method = "POST"
        , headers = [ authHeader token ]
        , url = url
        , body = body
        , expect = Http.expectJson (decodeApiResponse decoder)
        , timeout = Nothing
        , withCredentials = False
        }
