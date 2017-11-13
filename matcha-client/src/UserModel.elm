module UserModel exposing (..)

type alias User =
    { username : String
    , fname : String
    , lname : String
    , email : String
    , gender : Maybe Gender
    , intIn : Maybe Gender
    , bio : String
    , talks : List String
    , localisation : Maybe Localisation
    , photos : List String
    , role : UserRole
    }

type alias CurrentUser =
    { username : String
    , gender : Maybe Gender
    , bio : String
    , match : MatchStatus
    , has_talk : Bool
    }

type alias LocalisationApi =
  { status: String
  , lon: Maybe Float
  , lat: Maybe Float
  }

type alias Localisation =
  { lon: Float
  , lat: Float
  }

type Gender
    = M
    | F

type MatchStatus
    = None
    | From
    | To
    | Match


type UserRole
  = ADMIN
  | USER



genderToString : Maybe Gender -> String
genderToString g =
    case g of
        Just M -> "M"
        Just F -> "F"
        _ -> "No gender"

stringToGender : String -> Maybe Gender
stringToGender g =
    case g of
        "M" -> Just M
        "F" -> Just F
        _ -> Nothing

stringToMatch : String -> MatchStatus
stringToMatch m =
    case m of
        "from" -> From
        "to" -> To
        "match" -> Match
        _ -> None
