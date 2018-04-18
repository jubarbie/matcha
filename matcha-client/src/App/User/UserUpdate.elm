module App.User.UserUpdate exposing (..)

import App.User.UserModel exposing (..)

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

updateUsers : UsersModel -> List User -> UsersModel
updateUsers model users =
  { model | users = users }

updateUser : UsersModel -> User -> UsersModel
updateUser model user =
  { model | users = List.map (\u -> if (user.username == u.username) then { user | photos = sortPhotos user.photos } else u) model.users }

sortPhotos : List (Int, String, Bool) -> List  (Int, String, Bool)
sortPhotos photos =
  List.sortBy (\(a, b, c) -> toString c) photos |> List.reverse
