module DateUtils exposing (..)

import Date
import String

formatDate : Date.Date -> String
formatDate date =
  let
    year = toString <| Date.year date
    month =
      case Date.month date of
        Date.Jan -> "jan"
        Date.Feb -> "feb"
        Date.Mar -> "mar"
        Date.Apr -> "apr"
        Date.May -> "may"
        Date.Jun -> "jun"
        Date.Jul -> "jul"
        Date.Aug -> "aug"
        Date.Sep -> "sep"
        Date.Oct -> "oct"
        Date.Nov -> "nov"
        Date.Dec -> "dec"
    day = toString <| Date.day date
    h = toString <| Date.hour date
    m = toString <| Date.minute date
    s = toString <| Date.second date
  in
    day ++ " " ++ month ++ " " ++ year ++ " " ++ h ++ ":" ++ m ++ ":" ++ s
