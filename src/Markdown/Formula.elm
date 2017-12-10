module Markdown.Formula exposing (..)

import Combine exposing (..)
import Combine.Char exposing (..)
import Markdown.Block as Block exposing (Block)
import Markdown.Block.Extra as Block
import Markdown.Inline as Inline exposing (Inline)


type Formula
    = Formula String


parseFormulaInBlock : Block b Formula -> Block b Formula
parseFormulaInBlock =
    Block.walkInlinesWithConcat parseFormulaInline


parseFormulaInline : Inline Formula -> List (Inline Formula)
parseFormulaInline inline =
    case inline of
        Inline.Text text ->
            case parseFormula text of
                [] ->
                    [ inline ]

                [ _ ] ->
                    [ inline ]

                inlines ->
                    inlines

        _ ->
            [ inline ]


parseFormula : String -> List (Inline Formula)
parseFormula text =
    case Combine.parse withFormula text of
        Result.Err ( (), stream, _ ) ->
            if stream.data == "" then
                []
            else
                [ Inline.Text stream.data ]

        Result.Ok ( (), stream, ( txt, exp ) ) ->
            Inline.Text txt
                :: Inline.Custom (Formula exp) []
                :: parseFormula stream.input


withFormula : Parser s ( String, String )
withFormula =
    (,) <$> (String.concat <$> many noneDal) <*> formula


formula : Parser s String
formula =
    String.concat
        <$> between (string "$") (string "$") (many term)


term : Parser s String
term =
    escapedChar <|> noneDal


noneDal : Parser s String
noneDal =
    String.fromChar <$> noneOf [ '$' ]


escapedChar : Parser s String
escapedChar =
    String.append <$> string "\\" <*> (String.fromChar <$> anyChar)
