module UserModel exposing (..)

type alias SessionUser =
    { username : String
    , fname : String
    , lname : String
    , email : String
    , gender : Maybe Gender
    , intIn : List Gender
    , bio : String
    , talks : List String
    , tags : List String
    , localisation : Maybe Localisation
    , photos : List String
    , role : UserRole
    , status : UserStatus
    }

type alias User =
    { username : String
    , gender : Maybe Gender
    , bio : String
    , match : MatchStatus
    , has_talk : Bool
    , photos : List String
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

type UserStatus
  = Activated
  | ResetPassword
  | Incomplete
  | NotActivated



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
