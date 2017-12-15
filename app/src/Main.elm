module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import HtmlParser as Html
import HtmlParser.Util as Html
import Markdown.Block as Block exposing (Block)
import Markdown.Block.Extra as Block
import Markdown.Config exposing (HtmlOption(..))
import Markdown.Formula exposing (Formula(..), parseFormulaInBlock)
import Markdown.Inline as Inline exposing (Inline)
import Port.FS as FS
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
        , subscriptions = subscriptions
        }


type alias Model =
    { textarea : String
    , window : Window.Size
    , filepath : String
    }


model : Model
model =
    { textarea = ""
    , window = { width = 0, height = 0 }
    , filepath = ""
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
    | ReadFile FS.File
    | WriteFileHook (Maybe String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextAreaInput str ->
            ( { model | textarea = str }, Cmd.none )

        SizeUpdated size ->
            ( { model | window = size }, Cmd.none )

        ReadFile file ->
            ( { model | textarea = file.body, filepath = file.path }, Cmd.none )

        WriteFileHook (Just filepath) ->
            ( model, FS.writeFile { path = filepath, body = model.textarea } )

        WriteFileHook Nothing ->
            ( model, FS.writeFile { path = model.filepath, body = model.textarea } )


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
    textarea
        |> Block.parse Nothing
        |> Utils.split ((==) Block.ThematicBreak)
        |> List.map (toSlide window)
        |> div []


toSlide : Window.Size -> List (Block b Formula) -> Html msg
toSlide window blocks =
    let
        attrs =
            if Block.isHeadPage blocks then
                [ class "headPage" ]
            else
                []
    in
    blocks
        |> List.map (Block.walk parseFormulaInBlock)
        |> List.concatMap customHtmlBlock
        |> slideView window attrs


slideView : Window.Size -> List (Attribute msg) -> List (Html msg) -> Html msg
slideView window attrs slide =
    div (attrs ++ [ class "slide", slideSize window ])
        [ div [ class "slideContents" ] slide ]


customHtmlBlock : Block b Formula -> List (Html msg)
customHtmlBlock block =
    case block of
        Block.CodeBlock (Block.Fenced _ fence) code ->
            let
                language =
                    Maybe.withDefault "" fence.language

                toHighlight_ =
                    if List.member language [ "katex", "Katex" ] then
                        Utils.toKatex >> divFormula
                    else
                        Utils.toHighlight language >> precode language
            in
            code
                |> toHighlight_
                |> Html.parse
                |> Html.toVirtualDom

        _ ->
            block
                |> Block.defaultHtml
                    (Just customHtmlBlock)
                    (Just customHtmlInline)


divFormula : String -> String
divFormula code =
    "<div class=\"formula\">" ++ code ++ "</div>"


precode : String -> String -> String
precode lang code =
    "<pre><code class=\"" ++ lang ++ "\">" ++ code ++ "</code></pre>"


customHtmlInline : Inline Formula -> Html msg
customHtmlInline inline =
    case inline of
        Inline.Custom (Formula txt) _ ->
            Utils.toKatex txt
                |> Html.parse
                |> Html.toVirtualDom
                |> span []

        _ ->
            Inline.defaultHtml (Just customHtmlInline) inline


formulaHtmlInline : Inline Formula -> Html msg
formulaHtmlInline inline =
    case inline of
        -- Inline.CodeInine text ->
        _ ->
            Inline.defaultHtml (Just formulaHtmlInline) inline



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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes SizeUpdated
        , FS.readFile ReadFile
        , FS.writeFileHook WriteFileHook
        ]



-- Readme


readmeMD : String
readmeMD =
    ""
