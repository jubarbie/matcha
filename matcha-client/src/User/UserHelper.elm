module User.UserHelper exposing (..)

import User.UserModel exposing (..)

findUserByName: String -> Users -> Maybe User
findUserByName username users =
  List.head <| List.filter (\u -> username == u.username) users

getMatchStatus : User -> MatchStatus
getMatchStatus user =
  case (user.liked, user.liking) of
    (False, False) -> None
    (True, False) -> From
    (False, True) -> To
    (True, True) -> Match

getCommonTags : List String -> List String -> Int
getCommonTags tags1 tags2 =
  List.map (\t -> if (List.member t tags1) then 1 else 0) tags2
  |> List.sum

getAffinityScore : SessionUser -> User -> Float
getAffinityScore me user =
  (1 / (user.distance + 1)) * (40.0 / 100.0) + (toFloat ((user.likes) * (getCommonTags me.tags user.tags)) * 50.0 / 100) + ((toFloat user.likes) * 10.0 / 100)
