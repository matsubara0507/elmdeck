module Utils exposing (..)

import List
import List.Extra as List
import Native.Highlight
import Native.Katex


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


toKatex : String -> String
toKatex =
    Native.Katex.toKatex


undefined : () -> a
undefined =
    \_ -> Debug.crash "undefined..."
