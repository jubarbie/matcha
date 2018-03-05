module Routing exposing (..)

import Navigation exposing (Location)
import App.AppModels exposing (AppRoutes(..))
import Login.LoginModels exposing (LoginRoutes(..))
import UrlParser exposing (..)


matchersLogin : Parser (LoginRoutes -> a) a
matchersLogin =
    oneOf
    [ map LoginRoute top
    , map LoginRoute (s "login")
    , map SigninRoute (s "signup")
    , map ResetPwdRoute (s "password_reset")
    ]

matchersApp : Parser (AppRoutes -> a) a
matchersApp =
    oneOf
    [ map (UsersRoute "all") top
    , map (UsersRoute "all") (s "users")
    , map UsersRoute (s "users" </> string)
    , map UserRoute (s "user" </> string )
    , map SearchRoute (s "search")
    , map AccountRoute (s "account")
    , map EditAccountRoute (s "edit_account")
    , map ChangePwdRoute (s "edit_password")
    ]

parseLoginLocation : Location -> LoginRoutes
parseLoginLocation location =
    case (parseHash matchersLogin location) of
        Just route ->
            route

        Nothing ->
            NotFoundLoginRoute

parseAppLocation : Location -> AppRoutes
parseAppLocation location =
    case (parseHash matchersApp location) of
        Just route ->
            route

        Nothing ->
            NotFoundAppRoute
