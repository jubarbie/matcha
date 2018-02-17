module User.UserModel exposing (..)


type alias SessionUser =
    { username : String
    , fname : String
    , lname : String
    , email : String
    , gender : Maybe Gender
    , intIn : List Gender
    , bio : String
    , date_of_birth : Int
    , tags : List String
    , localisation : Localisation
    , photos : List ( Int, String )
    , role : UserRole
    , status : UserStatus
    }


type alias User =
    { username : String
    , gender : Maybe Gender
    , bio : String
    , date_of_birth : Int
    , liking : Bool
    , liked : Bool
    , likes : Int
    , has_talk : Bool
    , visitor : Bool
    , tags : List String
    , photos : List String
    , lastOn : String
    , distance : Float
    }

type alias Users =
    List User


type alias LocalisationApi =
    { status : String
    , lon : Maybe Float
    , lat : Maybe Float
    }


type alias Localisation =
    { lon : Float
    , lat : Float
    }

type FilterUsers
    = F_Visitors
    | F_Liked

type SortUsers
    = S_Age
    | S_LastOn
    | S_Dist
    | S_Afin

type OrderSort
  = ASC
  | DESC

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
        Just M ->
            "M"

        Just F ->
            "F"

        _ ->
            "No gender"

stringToGender : String -> Maybe Gender
stringToGender g =
    case g of
        "M" ->
            Just M

        "F" ->
            Just F

        _ ->
            Nothing


stringToMatch : String -> MatchStatus
stringToMatch m =
    case m of
        "from" ->
            From

        "to" ->
            To

        "match" ->
            Match

        _ ->
            None
