module App.User.UserHelper exposing (..)

import App.User.UserModel exposing (..)
import App.AppModels exposing (..)

isMainImage : ( Int, String, Bool ) -> Bool
isMainImage ( a, b, c ) =
    c
    
getOnlineStatus: AppModel -> User -> Bool
getOnlineStatus model user =
  case ( String.toFloat user.lastOn, model.currentTime ) of
    ( Ok l, Just ct ) ->
        if l > ct - 7200000 && user.online then
            True
        else
            False

    _ ->
        False

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
  (1 / (user.distance + 1) * 0.4) + (toFloat ((user.likes) * (getCommonTags me.tags user.tags)) * 0.5) + ((toFloat user.likes) * 0.1)

toggleOrder : OrderSort -> OrderSort
toggleOrder order =
  if order == ASC then DESC else ASC

applyUserFilter : FilterUsers -> User -> Bool
applyUserFilter fil u =
  case fil of
    F_MinAge a -> filterMinAge a u
    F_MaxAge a -> filterMaxAge a u
    F_Loc a -> filterLoc a u
    F_Tags a -> filterTags a u

filterMinAge : Int -> User -> Bool
filterMinAge min_ user =
  let
    age = 2018 - user.date_of_birth
  in
    (age >= min_)

filterMaxAge : Int -> User -> Bool
filterMaxAge max_ user =
  let
    age = 2018 - user.date_of_birth
  in
    (age <= max_)

filterLoc : Float -> User -> Bool
filterLoc dist user =
  (user.distance <= dist)

filterTags : (List String) -> User -> Bool
filterTags tags user =
  List.map (\t -> List.member t user.tags) tags |> List.foldl (&&) True

filterUser : List FilterUsers -> User -> Bool
filterUser filters u =
  List.map (\f -> applyUserFilter f u) filters |> List.foldl (&&) True

isFilterTag : FilterUsers -> Bool
isFilterTag filter_ =
  case filter_ of
    F_Tags a -> True
    _ -> False

isMinFilter : FilterUsers -> Bool
isMinFilter filter_ =
  case filter_ of
    F_MinAge a -> True
    _ -> False

isMaxFilter : FilterUsers -> Bool
isMaxFilter filter_ =
  case filter_ of
    F_MaxAge a -> True
    _ -> False

isLocFilter : FilterUsers -> Bool
isLocFilter filter_ =
  case filter_ of
    F_Loc a -> True
    _ -> False

updateFilterTag : List FilterUsers -> String -> List FilterUsers
updateFilterTag filters tag_ =
  case List.filter isFilterTag filters of
    a :: b -> updateTagListFilter filters tag_
    _ -> (F_Tags [tag_]) :: filters

updateTagListFilter : List FilterUsers -> String -> List FilterUsers
updateTagListFilter filters tag_ =
  List.map (\f ->
    case f of
      F_Tags a ->
        if (List.member tag_ a) then
          F_Tags <| List.filter (\t -> t /= tag_) a
        else
          F_Tags <| tag_ :: a
      _ -> f
  ) filters

getFilterTags : List FilterUsers -> List String
getFilterTags filters =
  case List.filter isFilterTag filters of
    (F_Tags a) :: b -> a
    _ -> []

updateMinAgeFilter : List FilterUsers -> Int -> List FilterUsers
updateMinAgeFilter filters age =
  case List.filter isMinFilter filters of
    a :: b -> (F_MinAge age) :: (List.filter (\f -> not <| isMinFilter f) filters)
    _ -> (F_MinAge age) :: filters

updateMaxAgeFilter : List FilterUsers -> Int -> List FilterUsers
updateMaxAgeFilter filters age =
  case List.filter isMaxFilter filters of
    a :: b -> (F_MaxAge age) :: (List.filter (\f -> not <| isMaxFilter f ) filters)
    _ -> (F_MaxAge age) :: filters

updateLocFilter : List FilterUsers -> Float -> List FilterUsers
updateLocFilter filters dist =
  case List.filter isLocFilter filters of
    a :: b -> (F_Loc dist) :: (List.filter (\f -> not <| isLocFilter f) filters)
    _ -> (F_Loc dist) :: filters
