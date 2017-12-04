module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick, onInput)
import Markdown.Block as Block exposing (Block)
import Markdown.Config exposing (HtmlOption(..), defaultOptions, defaultSanitizeOptions)
import Markdown.Inline as Inline
import Regex


main : Program Never Model Msg
main =
    Html.program
        { init = init ! []
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { textarea : String
    , options : Markdown.Config.Options
    , showToC : Bool
    }


init : Model
init =
    { textarea = readmeMD
    , options = defaultOptions
    , showToC = False
    }


type Msg
    = TextAreaInput String
    | SoftAsHardLineBreak Bool
    | HtmlOption HtmlOption
    | ShowToC Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextAreaInput str ->
            { model | textarea = str } ! []

        SoftAsHardLineBreak bool ->
            let
                options =
                    model.options

                updtOptions =
                    { options
                        | softAsHardLineBreak = bool
                    }
            in
            { model | options = updtOptions } ! []

        HtmlOption htmlConfig ->
            let
                options =
                    model.options

                updtOptions =
                    { options
                        | rawHtml = htmlConfig
                    }
            in
            { model | options = updtOptions } ! []

        ShowToC bool ->
            { model | showToC = bool } ! []


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
            , h2 [] [ text "Options" ]
            , optionsView model
            , h2 [] [ text "Custom" ]
            , label []
                [ input
                    [ type_ "checkbox"
                    , onCheck ShowToC
                    , checked model.showToC
                    ]
                    []
                , text " Show dynamic Table of Content"
                ]
            ]
        , markdownView model
        ]
    ]
        |> div []


optionsView : Model -> Html Msg
optionsView { options } =
    [ li []
        [ label []
            [ input
                [ type_ "checkbox"
                , onCheck SoftAsHardLineBreak
                , checked options.softAsHardLineBreak
                ]
                []
            , text " softAsHardLineBreak"
            ]
        ]
    , li []
        [ b [] [ text "rawHtml:" ]
        , ul [ listStyle ]
            [ rawHtmlItem options "ParseUnsafe" ParseUnsafe
            , rawHtmlItem options "Sanitize defaultAllowed" <|
                Sanitize defaultSanitizeOptions
            , rawHtmlItem options "DontParse" DontParse
            ]
        ]
    ]
        |> ul [ listStyle ]


rawHtmlItem : Markdown.Config.Options -> String -> HtmlOption -> Html Msg
rawHtmlItem { rawHtml } value msg =
    [ label []
        [ input
            [ type_ "radio"
            , name "htmlOption"
            , onClick (HtmlOption msg)
            , checked (rawHtml == msg)
            ]
            []
        , text value
        ]
    ]
        |> li []


markdownView : Model -> Html Msg
markdownView { options, textarea, showToC } =
    let
        blocks =
            Block.parse (Just options) textarea

        blocksView =
            List.concatMap customHtmlBlock blocks
    in
    if showToC then
        blocksView
            |> (::) (tocView blocks)
            |> div [ width50Style ]
    else
        blocksView
            |> div [ width50Style ]



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



-- Table of Content


tocView : List (Block b i) -> Html Msg
tocView =
    List.concatMap (Block.query getHeading)
        >> List.foldl organizeHeadings []
        >> List.reverse
        >> List.map reverseToCItem
        >> tocViewHelp
        >> flip (::) []
        >> (::) (h1 [] [ text "Table of Content" ])
        >> div []


getHeading : Block b i -> List ( Int, String )
getHeading block =
    case block of
        Block.Heading _ lvl inlines ->
            [ ( lvl, Inline.extractText inlines ) ]

        _ ->
            []


type ToCItem
    = Item Int String (List ToCItem)


organizeHeadings : ( Int, String ) -> List ToCItem -> List ToCItem
organizeHeadings ( lvl, str ) items =
    case items of
        [] ->
            [ Item lvl str [] ]

        (Item lvl_ str_ items_) :: tail ->
            if lvl <= lvl_ then
                Item lvl str [] :: items
            else
                organizeHeadings ( lvl, str ) items_
                    |> Item lvl_ str_
                    |> flip (::) tail


reverseToCItem : ToCItem -> ToCItem
reverseToCItem (Item lvl heading subHeadings) =
    List.reverse subHeadings
        |> List.map reverseToCItem
        |> Item lvl heading


tocViewHelp : List ToCItem -> Html Msg
tocViewHelp =
    List.map tocItemView
        >> ul []


tocItemView : ToCItem -> Html Msg
tocItemView (Item lvl heading subHeadings) =
    if List.isEmpty subHeadings then
        li [] [ tocLinkView heading ]
    else
        li []
            [ tocLinkView heading
            , tocViewHelp subHeadings
            ]


tocLinkView : String -> Html Msg
tocLinkView str =
    a
        [ formatToCLink str
            |> (++) "#"
            |> Html.Attributes.href
        ]
        [ text str ]


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


listStyle : Attribute msg
listStyle =
    style
        [ ( "list-style", "none" )
        ]



-- Readme


readmeMD : String
readmeMD =
    ""
