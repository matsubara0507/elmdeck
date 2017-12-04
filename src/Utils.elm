module Utils exposing (..)

import List
import List.Extra as List
import Native.Highlight


split : (a -> Bool) -> List a -> List (List a)
split p xs =
    case List.dropWhile p xs of
        [] ->
            []

        ys ->
            let
                ( x, zs ) =
                    List.break p ys
            in
            x :: split p zs


toHighlight : String -> String -> String
toHighlight =
    Native.Highlight.toHighlight
