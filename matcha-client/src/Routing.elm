module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (Route(..), LoginRoute(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
    [ map (Connect Login) top
    , map (Connect Login) (s "login")
    , map (Connect Signin) (s "signup")
    , map (Connect ResetPwdRoute) (s "password_reset")
    , map (UsersRoute "all") (s "users")
    , map (UsersRoute) (s "users" </> string)
    , map (UserRoute) (s "user" </> string )
    , map ChatRoute (s "chat" </> string)
    , map ChatsRoute (s "chat")
    , map AccountRoute (s "account")
    , map EditAccountRoute (s "edit_account")
    , map ChangePwdRoute (s "edit_password")
    ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
