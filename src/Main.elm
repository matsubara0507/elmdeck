module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Markdown.Block as Block exposing (Block)
import Markdown.Config exposing (HtmlOption(..))
import Markdown.Inline as Inline
import Regex


main : Program Never Model Msg
main =
    Html.program
        { init = ( init, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { textarea : String
    }


init : Model
init =
    { textarea = ""
    }


type Msg
    = TextAreaInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextAreaInput str ->
            ( { model | textarea = str }, Cmd.none )


view : Model -> Html Msg
view model =
    [ div [ displayFlex ]
        [ div [ width50Style ]
            [ textarea
                [ onInput TextAreaInput
                , defaultValue model.textarea
                , textareaStyle
                ]
                []
            ]
        , div [ width50Style, style [ ( "background", "#4c4b4b" ) ] ]
            [ markdownView model ]
        ]
    ]
        |> div []


markdownView : Model -> Html Msg
markdownView { textarea } =
    let
        blocks =
            Block.parse Nothing textarea

        blocksView =
            List.concatMap customHtmlBlock blocks

        style_ =
            style
                [ ( "width", "90%" )
                , ( "background", "white" )
                , ( "margin", "auto" )
                ]
    in
    blocksView
        |> div [ style_ ]



-- Heading Link


customHtmlBlock : Block b i -> List (Html msg)
customHtmlBlock block =
    case block of
        Block.Heading _ level inlines ->
            let
                hElement =
                    case level of
                        1 ->
                            h1

                        2 ->
                            h2

                        3 ->
                            h3

                        4 ->
                            h4

                        5 ->
                            h5

                        _ ->
                            h6
            in
            [ hElement
                [ Html.Attributes.id
                    (formatToCLink
                        (Inline.extractText inlines)
                    )
                ]
                (List.map Inline.toHtml inlines)
            ]

        _ ->
            Block.defaultHtml
                (Just customHtmlBlock)
                Nothing
                block


formatToCLink : String -> String
formatToCLink =
    String.toLower
        >> Regex.replace Regex.All (Regex.regex "\\s+") (always "-")



-- Styles


displayFlex : Attribute msg
displayFlex =
    style [ ( "display", "flex" ) ]


width50Style : Attribute msg
width50Style =
    style [ ( "width", "50%" ) ]


textareaStyle : Attribute msg
textareaStyle =
    style
        [ ( "width", "90%" )
        , ( "height", "400px" )
        ]



-- Readme


readmeMD : String
readmeMD =
    ""
