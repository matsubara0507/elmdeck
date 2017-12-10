module Markdown.Block.Extra exposing (..)

import Function.Extra as Function
import Markdown.Block exposing (..)
import Markdown.Inline as Inline exposing (Inline)
import Markdown.Inline.Extra as Inline


walkInlinesWithConcat : (Inline i -> List (Inline i)) -> Block b i -> Block b i
walkInlinesWithConcat function block =
    walk (walkInlinesWithConcatHelper function) block


walkInlinesWithConcatHelper : (Inline i -> List (Inline i)) -> Block b i -> Block b i
walkInlinesWithConcatHelper function block =
    case block of
        Paragraph rawText inlines ->
            List.concatMap (Inline.walkWithConcat function) inlines
                |> Paragraph rawText

        Heading rawText level inlines ->
            List.concatMap (Inline.walkWithConcat function) inlines
                |> Heading rawText level

        PlainInlines inlines ->
            List.concatMap (Inline.walkWithConcat function) inlines
                |> PlainInlines

        _ ->
            block


isHeadPage : List (Block b i) -> Bool
isHeadPage =
    List.all (Function.map2 (||) isBlankLine isHeading)


isBlankLine : Block b i -> Bool
isBlankLine block =
    case block of
        BlankLine _ ->
            True

        _ ->
            False


isHeading : Block b i -> Bool
isHeading block =
    case block of
        Heading _ _ _ ->
            True

        _ ->
            False
