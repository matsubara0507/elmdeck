module Markdown.Block.Extra exposing (..)

import Function.Extra as Function
import Markdown.Block as Block exposing (Block)


isHeadPage : List (Block b i) -> Bool
isHeadPage =
    List.all (Function.map2 (||) isBlankLine isHeading)


isBlankLine : Block b i -> Bool
isBlankLine block =
    case block of
        Block.BlankLine _ ->
            True

        _ ->
            False


isHeading : Block b i -> Bool
isHeading block =
    case block of
        Block.Heading _ _ _ ->
            True

        _ ->
            False
