module App.AppUtils exposing (..)

import App.User.UserModel exposing (..)


getAccountNotif : SessionUser -> Int
getAccountNotif user =
  let
    may a = if a == Nothing then 1 else 0
    str a = case a of
      Just "" -> 1
      Nothing -> 1
      _ -> 0
    lst a = if a == [] then 1 else 0
    notif
      = may user.date_of_birth
      + str user.bio
      + may user.gender
      + lst user.intIn
      + lst user.photos
  in
    notif
