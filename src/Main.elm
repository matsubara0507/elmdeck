module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Markdown.Block as Block exposing (Block)
import Markdown.Config exposing (HtmlOption(..))
import Markdown.Inline as Inline
import Regex
import Task
import Utils
import Window


main : Program Never Model Msg
main =
    Html.program
        { init = init model
        , view = view
        , update = update
        , subscriptions = \_ -> Window.resizes SizeUpdated
        }


type alias Model =
    { textarea : String
    , window : Window.Size
    }


model : Model
model =
    { textarea = ""
    , window = { width = 0, height = 0 }
    }


init : Model -> ( Model, Cmd Msg )
init model =
    ( model
    , Window.size
        |> Task.perform SizeUpdated
    )


type Msg
    = TextAreaInput String
    | SizeUpdated Window.Size


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextAreaInput str ->
            ( { model | textarea = str }, Cmd.none )

        SizeUpdated size ->
            ( { model | window = size }, Cmd.none )


view : Model -> Html Msg
view model =
    [ div [ displayFlex ]
        [ div [ halfStyle model.window ]
            [ textarea
                [ onInput TextAreaInput
                , defaultValue model.textarea
                , textareaStyle
                ]
                []
            ]
        , div [ class "slides", halfStyle model.window ]
            [ markdownView model ]
        ]
    ]
        |> div []


markdownView : Model -> Html Msg
markdownView { textarea, window } =
    let
        blocks =
            Block.parse Nothing textarea

        blocksView =
            blocks
                |> Utils.split ((==) Block.ThematicBreak)
                |> List.map (List.concatMap customHtmlBlock)
    in
    blocksView
        |> List.map (slideView window)
        |> div []


slideView : Window.Size -> List (Html msg) -> Html msg
slideView window slide =
    div [ class "slide", slideSize window ]
        [ div [ class "slideContents" ] slide ]



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


halfStyle : Window.Size -> Attribute msg
halfStyle window =
    let
        height_ =
            round (0.8 * toFloat window.height)
    in
    style
        [ ( "width", "50%" )
        , ( "height", toString height_ ++ "px" )
        ]


textareaStyle : Attribute msg
textareaStyle =
    style
        [ ( "width", "98%" )
        , ( "height", "100%" )
        ]


slideSize : Window.Size -> Attribute msg
slideSize window =
    let
        width_ =
            round (0.45 * toFloat window.width)

        height_ =
            width_ // 4 * 3
    in
    style
        [ ( "width", toString width_ ++ "px" )
        , ( "height", toString height_ ++ "px" )
        ]



-- Readme


readmeMD : String
readmeMD =
    ""
