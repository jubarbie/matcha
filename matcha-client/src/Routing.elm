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
    , map (UsersRoute) (s "users")
    , map (UserRoute) (s "user" </> string )
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
