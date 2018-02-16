module User.UserHelper exposing (..)

import User.UserModel exposing (..)

findUserByName: String -> Users -> Maybe User
findUserByName username users =
  List.head <| List.filter (\u -> username == u.username) users

distanceCmp a b =
    case (a.distance, b.distance) of
      (Just d1, Just d2) -> compare d1 d2
      (Just d1, _ ) -> LT
      _ -> EQ

getMatchStatus : User -> MatchStatus
getMatchStatus user =
  case (user.liked, user.liking) of
    (False, False) -> None
    (True, False) -> From
    (False, True) -> To
    (True, True) -> Match
