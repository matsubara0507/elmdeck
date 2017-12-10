module Markdown.Inline.Extra exposing (..)

import Markdown.Inline exposing (..)


walkWithConcat : (Inline i -> List (Inline i)) -> Inline i -> List (Inline i)
walkWithConcat function inline =
    case inline of
        Link url maybeTitle inlines ->
            List.concatMap (walkWithConcat function) inlines
                |> Link url maybeTitle
                |> function

        Image url maybeTitle inlines ->
            List.concatMap (walkWithConcat function) inlines
                |> Image url maybeTitle
                |> function

        HtmlInline tag attrs inlines ->
            List.concatMap (walkWithConcat function) inlines
                |> HtmlInline tag attrs
                |> function

        Emphasis length inlines ->
            List.concatMap (walkWithConcat function) inlines
                |> Emphasis length
                |> function

        _ ->
            function inline
