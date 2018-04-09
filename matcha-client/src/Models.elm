module Models exposing (..)

import Api.ApiModel exposing (..)
import App.AppModels exposing (..)
import App.Notif.NotifModel exposing (..)
import App.Talk.TalkModel exposing (..)
import App.User.UserModel exposing (..)
import FormUtils exposing (..)
import Login.LoginModels exposing (..)
import Time exposing (..)


type Model
    = NotConnected LoginRoutes LoginModel
    | Connexion AppRoutes
    | Connected AppRoutes Session AppModel UsersModel TalksModel


initialModel : LoginRoutes -> Model
initialModel route =
    NotConnected route initialLoginModel


type alias AuthResponse =
    { status : Bool
    , message : Maybe String
    , token : Maybe String
    , user : Maybe SessionUser
    }
