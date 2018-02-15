module User.UserUpdate exposing (..)

import User.UserModel exposing (..)

updateUser: User -> Users -> Users
updateUser user users =
  List.map (\u -> if (user.username == u.username) then user else u) users
