module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


---- MODEL ----


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
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


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
