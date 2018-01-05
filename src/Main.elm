module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


---- MODEL ----


type alias TextTranslation =
    { text : String
    , translations : List String
    }


type alias TextSound =
    { text : String
    , sound : String
    }


type alias BlockQuestion =
    { sentence : List TextTranslation
    , words : List TextSound
    }


type alias Flags =
    { blockQuestions : List BlockQuestion }


type alias Model =
    { blockQuestions : List BlockQuestion
    , selectedIndexes : List Int
    }


init : Flags -> ( Model, Cmd Msg )
init { blockQuestions } =
    ( { blockQuestions = blockQuestions, selectedIndexes = [] }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | SelectBlock Int
    | UnselectBlock Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SelectBlock index ->
            ( { model | selectedIndexes = model.selectedIndexes ++ [ index ] }, Cmd.none )

        UnselectBlock index ->
            let
                newSelectedIndexes =
                    List.take index model.selectedIndexes
                        ++ List.drop (index + 1) model.selectedIndexes
            in
            ( { model | selectedIndexes = newSelectedIndexes }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        maybeQuestion =
            List.head model.blockQuestions
    in
    div
        [ style
            [ ( "max-width", "500px" )
            , ( "margin", "0 auto" )
            , ( "padding", "1em" )
            ]
        ]
        [ viewProgressBar
        , h1 [] [ text "Translate this sentence" ]
        , viewSentence
        , viewLines
        , case maybeQuestion of
            Nothing ->
                div [] [ text "Make sure there's at least 1 question..." ]

            Just question ->
                viewWordBlocks model.selectedIndexes (List.map .text question.words)
        , viewButton
        ]


viewProgressBar : Html Msg
viewProgressBar =
    div
        [ style
            [ ( "display", "flex" )
            , ( "align-items", "center" )
            ]
        ]
        [ div
            [ style
                [ ( "flex", "1" )
                , ( "font-size", "40px" )
                , ( "color", "#ccc" )
                ]
            ]
            [ text "✕" ]
        , div
            [ style
                [ ( "flex", "9" )
                , ( "max-width", "500px" )
                , ( "height", "5px" )
                , ( "background", "#ccc" )
                , ( "margin-left", "0.5em" )
                ]
            ]
            []
        ]


sentence : List String
sentence =
    String.split " " "I stuck on a stamp"


viewSentence : Html Msg
viewSentence =
    div [ style [ ( "margin", "15px" ) ] ] (List.map viewWord sentence)


viewWord : String -> Html Msg
viewWord word =
    span
        [ style
            [ ( "border-bottom", "1px dashed #aaa" )
            , ( "padding", "5px 0" )
            , ( "margin", "0 5px" )
            ]
        ]
        [ text word ]


viewLines : Html Msg
viewLines =
    div []
        (List.repeat 3
            (div
                [ style
                    [ ( "width", "100%" )
                    , ( "height", "1px" )
                    , ( "background", "#ccc" )
                    , ( "margin", "40px 0" )
                    ]
                ]
                []
            )
        )


viewWordBlocks : List Int -> List String -> Html Msg
viewWordBlocks selectedBlocks words =
    div
        [ style
            [ ( "margin", "0 0 50px" )
            , ( "display", "flex" )
            , ( "flex-wrap", "wrap" )
            ]
        ]
        (List.indexedMap
            (\index word ->
                let
                    isSelected =
                        List.member index selectedBlocks
                in
                viewWordBlock isSelected index word
            )
            words
        )


viewWordBlock : Bool -> Int -> String -> Html Msg
viewWordBlock isSelected index word =
    if isSelected then
        span
            [ style
                [ ( "padding", "10px" )
                , ( "margin", "10px" )
                , ( "background", "#ddd" )
                , ( "color", "#ddd" )
                ]
            ]
            [ text word ]
    else
        span
            [ style
                [ ( "padding", "10px" )
                , ( "margin", "10px" )
                , ( "background", "white" )
                ]
            , onClick (SelectBlock index)
            ]
            [ text word ]


viewButton : Html Msg
viewButton =
    div
        [ style
            [ ( "font-size", "20px" )
            , ( "color", "#777" )
            , ( "background", "#ccc" )
            , ( "padding", "15px" )
            , ( "border-radius", "100px" )
            ]
        ]
        [ text "CHECK" ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
