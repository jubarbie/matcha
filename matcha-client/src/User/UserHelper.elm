module User.UserHelper exposing (..)

import User.UserModel exposing (..)

findUserByName: String -> Users -> Maybe User
findUserByName username users =
  List.head <| List.filter (\u -> username == u.username) users

updateUser: User -> Users -> Users
updateUser user users =
  List.map (\u -> if (user.username == u.username) then user else u) users
