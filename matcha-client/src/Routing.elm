module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (Route(..), LoginRoute(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
    [ map (Connect Login)  top
    , map (Connect Login) (s "login")
    , map (Connect Signin) (s "signin")
    , map (Users Nothing) (s "users")
    , map Chat (s "chat")
    , map Account (s "account")
    ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
