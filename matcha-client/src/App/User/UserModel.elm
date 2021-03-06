module App.User.UserModel exposing (..)


type alias UsersModel =
    { users : Users
    , currentUser : Maybe String
    , userFilter : List FilterUsers
    , userSort : SortUsers
    , orderSort : OrderSort
    }


type alias SessionUser =
    { username : String
    , fname : String
    , lname : String
    , email : String
    , gender : Maybe Gender
    , intIn : List Gender
    , bio : Maybe String
    , date_of_birth : Maybe Int
    , tags : List String
    , localisation : Localisation
    , photos : List ( Int, String, Bool )
    , status : UserStatus
    , rights : UserRole
    }


type alias User =
    { username : String
    , gender : Maybe Gender
    , bio : String
    , date_of_birth : Int
    , liking : Bool
    , liked : Bool
    , likes : Int
    , visits : Int
    , has_talk : Bool
    , visitor : Bool
    , tags : List String
    , photos : List ( Int, String, Bool )
    , lastOn : String
    , online : Bool
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
    = F_MinAge Int
    | F_MaxAge Int
    | F_Loc Float
    | F_Tags (List String)


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
    | NB
    | O


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


initialUsersModel =
    { users = []
    , currentUser = Nothing
    , userFilter = []
    , userSort = S_Afin
    , orderSort = ASC
    }


genderToString : Maybe Gender -> String
genderToString g =
    case g of
        Just M ->
            "M"

        Just F ->
            "F"

        Just NB ->
            "NB"

        Just O ->
            "O"

        _ ->
            "No gender"


stringToGender : String -> Maybe Gender
stringToGender g =
    case g of
        "M" ->
            Just M

        "F" ->
            Just F

        "NB" ->
            Just NB

        "O" ->
            Just O

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
