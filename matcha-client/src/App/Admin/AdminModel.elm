module App.Admin.AdminModel exposing (..)

import App.User.UserModel exposing (..)

type alias AdminModel =
    { users : AdminUsers
    , fetching : Bool
    , page : Int
    }

type AdminUsers
  = Reported (List SessionUser)
  | All (List SessionUser)


initAdminModel : AdminModel
initAdminModel =
  { users = All []
  , fetching = False
  , page = 1
  }
