module Login.LoginModels exposing (..)

import FormUtils exposing (..)
import App.User.UserModel

type LoginRoutes
    = LoginRoute
    | SigninRoute
    | ResetPwdRoute
    | NotFoundLoginRoute

type alias LoginModel =
  { loginForm : Form
  , newUserForm : Form
  , resetPwdForm : Form
  , localisation : App.User.UserModel.Localisation
  , message : Maybe String
  }

initialLoginModel : LoginModel
initialLoginModel =
  { loginForm = initLoginForm
  , newUserForm = initFastNewUserForm
  , resetPwdForm = initResetPwdForm
  , localisation = { lon = 0 , lat = 0 }
  , message = Nothing
  }
