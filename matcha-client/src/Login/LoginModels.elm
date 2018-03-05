module Login.LoginModels exposing (..)

import FormUtils exposing (..)

type LoginRoutes
    = LoginRoute
    | SigninRoute
    | ResetPwdRoute
    | NotFoundLoginRoute

type alias LoginModel =
  { loginForm : Form
  , newUserForm : Form
  , resetPwdForm : Form
  , message : Maybe String
  }

initialLoginModel : LoginModel
initialLoginModel =
  { loginForm = initLoginForm
  , newUserForm = initFastNewUserForm
  , resetPwdForm = initResetPwdForm
  , message = Nothing
  }
