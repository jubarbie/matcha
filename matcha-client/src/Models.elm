module Models exposing (..)

import FormUtils exposing (..)
import Time exposing (..)
import App.AppModels exposing (..)
import App.User.UserModel exposing (..)
import App.Talk.TalkModel exposing (..)
import App.Notif.NotifModel exposing (..)
import Api.ApiModel exposing (..)
import Login.LoginModels exposing (..)


type Model
  = NotConnected LoginRoutes LoginModel
  | Connexion AppRoutes
  | Connected AppRoutes Session AppModel UsersModel TalksModel

initialModel : LoginRoutes -> Model
initialModel route =
  NotConnected route initialLoginModel

type alias AuthResponse =
    { status : String
    , message : Maybe String
    , token : Maybe String
    , user : Maybe SessionUser
    }
