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
    , solutions : List String
    }


type alias Flags =
    { question : BlockQuestion
    , nextQuestions : List BlockQuestion
    }


type Answer
    = Unanswered
    | Correct
    | Incorrect String


type alias Model =
    { question : BlockQuestion
    , nextQuestions : List BlockQuestion
    , selectedIndexes : List Int
    , answer : Answer
    , correctCount : Int
    }


init : Flags -> ( Model, Cmd Msg )
init { question, nextQuestions } =
    ( { question = question
      , nextQuestions = nextQuestions
      , selectedIndexes = []
      , answer = Unanswered
      , correctCount = 1
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | SelectBlock Int
    | UnselectBlock Int
    | CheckAnswer
    | NextQuestion


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

        CheckAnswer ->
            let
                userAnswer =
                    List.map
                        (\index ->
                            List.drop index model.question.words
                                |> List.head
                                |> Maybe.map .text
                                |> Maybe.withDefault "x"
                        )
                        model.selectedIndexes
                        |> String.join ""

                answer =
                    if List.member userAnswer model.question.solutions then
                        Correct
                    else
                        Incorrect (List.head model.question.solutions |> Maybe.withDefault "")

                correctCount =
                    if answer == Correct then
                        model.correctCount + 1
                    else
                        model.correctCount
            in
            ( { model | answer = answer, correctCount = correctCount }, Cmd.none )

        NextQuestion ->
            case model.nextQuestions of
                [] ->
                    ( { model
                        | selectedIndexes = []
                        , answer = Unanswered
                      }
                    , Cmd.none
                    )

                question :: nextQuestions ->
                    ( { model
                        | question = question
                        , nextQuestions = nextQuestions
                        , selectedIndexes = []
                        , answer = Unanswered
                      }
                    , Cmd.none
                    )



---- VIEW ----


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "max-width", "500px" )
            , ( "margin", "0 auto" )
            , ( "padding", "1em" )
            , ( "height", "95vh" )
            , ( "position", "relative" )
            ]
        ]
        [ viewProgressBar model.correctCount
        , h1 [] [ text "Translate this sentence" ]
        , viewSentence (List.map .text model.question.sentence)
        , div
            [ style
                [ ( "display", "flex" )
                , ( "flex-direction", "column" )
                , ( "height", "60%" )
                ]
            ]
            [ div [ style [ ( "height", "50%" ), ( "position", "relative" ) ] ]
                [ div
                    [ style
                        [ ( "position", "absolute" )
                        , ( "width", "100%" )
                        , ( "height", "100%" )
                        , ( "z-index", "-1" )
                        ]
                    ]
                    [ viewLines ]
                , viewSelectedWordBlocks
                    (List.filterMap
                        (\index ->
                            List.drop index model.question.words
                                |> List.head
                                |> Maybe.map .text
                        )
                        model.selectedIndexes
                    )
                ]
            , viewResult model.answer
            , viewWordBlocks model.selectedIndexes (List.map .text model.question.words)
            ]
        , viewButton
            ((not << List.isEmpty) model.selectedIndexes)
            (model.answer /= Unanswered)
        ]


viewProgressBar : Int -> Html Msg
viewProgressBar correctCount =
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
                , ( "position", "relative" )
                ]
            ]
            [ div
                [ style
                    [ ( "width", toString (correctCount * 100 // 10) ++ "%" )
                    , ( "height", "12px" )
                    , ( "background", "#00d800" )
                    , ( "border-radius", "100px" )
                    , ( "position", "absolute" )
                    , ( "top", "-3px" )
                    , ( "left", "-1px" )
                    ]
                ]
                []
            ]
        ]


viewSentence : List String -> Html Msg
viewSentence sentence =
    div [ style [ ( "margin", "15px" ) ] ] (List.map viewWord sentence)


viewWord : String -> Html Msg
viewWord word =
    span
        [ style
            [ ( "border-bottom", "1px dashed #aaa" )
            , ( "padding", "5px 0" )
            , ( "margin", "0 5px" )
            , ( "cursor", "pointer" )
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
                    , ( "margin", "50px 0" )
                    ]
                ]
                []
            )
        )


viewSelectedWordBlocks : List String -> Html Msg
viewSelectedWordBlocks words =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-wrap", "wrap" )
            ]
        ]
        (List.indexedMap viewSelectedWordBlock words)


viewSelectedWordBlock : Int -> String -> Html Msg
viewSelectedWordBlock index word =
    span
        [ style
            [ ( "padding", "10px" )
            , ( "margin", "5px 10px" )
            , ( "background", "white" )
            , ( "cursor", "pointer" )
            ]
        , onClick (UnselectBlock index)
        ]
        [ text word ]


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
                , ( "margin", "5px 10px" )
                , ( "background", "#ddd" )
                , ( "color", "#ddd" )
                , ( "cursor", "default" )
                ]
            ]
            [ text word ]
    else
        span
            [ style
                [ ( "padding", "10px" )
                , ( "margin", "5px 10px" )
                , ( "background", "white" )
                , ( "cursor", "pointer" )
                ]
            , onClick (SelectBlock index)
            ]
            [ text word ]


viewResult : Answer -> Html Msg
viewResult answer =
    case answer of
        Unanswered ->
            text ""

        Correct ->
            div
                [ style
                    [ ( "color", "#13ad13" )
                    , ( "background", "#bdffa4" )
                    , ( "width", "90%" )
                    , ( "height", "100px" )
                    , ( "position", "absolute" )
                    , ( "top", "60%" )
                    , ( "font-size", "22px" )
                    , ( "display", "flex" )
                    , ( "flex-direction", "column" )
                    , ( "justify-content", "center" )
                    , ( "align-items", "center" )
                    ]
                ]
                [ text "You are correct." ]

        Incorrect solution ->
            div
                [ style
                    [ ( "color", "#ce0606" )
                    , ( "background", "#fdd9e0" )
                    , ( "width", "90%" )
                    , ( "height", "100px" )
                    , ( "position", "absolute" )
                    , ( "top", "60%" )
                    , ( "font-size", "22px" )
                    , ( "display", "flex" )
                    , ( "flex-direction", "column" )
                    , ( "justify-content", "center" )
                    , ( "align-items", "center" )
                    ]
                ]
                [ div [] [ text "Oops, that's not correct." ]
                , div [ style [ ( "font-size", "18px" ) ] ] [ text solution ]
                ]


viewButton : Bool -> Bool -> Html Msg
viewButton isActive isAnswered =
    div
        [ style
            [ ( "font-size", "20px" )
            , if isActive then
                ( "color", "white" )
              else
                ( "color", "#777" )
            , if isActive then
                ( "background", "#00d800" )
              else
                ( "background", "#ccc" )
            , ( "padding", "15px" )
            , ( "border-radius", "100px" )
            ]
        , if isActive then
            if isAnswered then
                onClick NextQuestion
            else
                onClick CheckAnswer
          else
            onClick NoOp
        ]
        [ text
            (if isAnswered then
                "CONTINUE"
             else
                "CHECK"
            )
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
