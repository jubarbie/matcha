module User.UserHelper exposing (..)

import User.UserModel exposing (..)

findUserByName: String -> Users -> Maybe User
findUserByName username users =
  List.head <| List.filter (\u -> username == u.username) users
