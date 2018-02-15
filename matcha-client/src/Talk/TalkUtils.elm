module Talk.TalkUtils exposing (..)

import Talk.TalkModel exposing (..)

getTalkWith : String -> List Talk -> Maybe Talk
getTalkWith username talks =
    List.head <| List.filter (\t -> t.username_with == username) talks


updateTalks : Maybe Talk -> List Talk -> List Talk
updateTalks newTalk talks =
    case newTalk of
        Just nt ->
          if (List.member nt talks) then
            List.map
                (\t ->
                    if nt.username_with == t.username_with then
                        nt
                    else
                        t
                )
                talks
            else
              nt :: talks

        _ ->
            talks


getTalkNotif : List Talk -> Int
getTalkNotif talks =
    List.sum <| List.map .unreadMsgs talks
