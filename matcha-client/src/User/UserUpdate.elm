module User.UserUpdate exposing (..)

import User.UserModel exposing (..)

updateUser: User -> Users -> Users
updateUser user users =
  List.map (\u -> if (user.username == u.username) then user else u) users

showImage : Int -> User -> Users -> Users
showImage to user users =
  List.map
  (\u ->
    if (user.username == u.username) then
      changeUserImage to user
    else u
  ) users

changeUserImage : Int -> User -> User
changeUserImage to user =
  case (user.photos, to) of
    ( a :: gal, 1) -> { user | photos = gal ++ [a] }
    ( gal, -1) -> { user | photos = List.drop (List.length gal - 1) gal ++ List.take (List.length gal - 1) gal }
    _ -> user
