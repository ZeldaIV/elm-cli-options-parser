module Main exposing (main)

import Cli.Option as Option
import Cli.OptionsParser as OptionsParser exposing (with)
import Cli.OptionsParser.BuilderState
import Cli.Program as Program
import Cli.Validate
import Json.Decode exposing (..)
import Ports


programConfig : Program.Config GreetOptions
programConfig =
    Program.config { version = "1.2.3" }
        |> Program.add validateParser


capitalizedNameRegex : String
capitalizedNameRegex =
    "[A-Z][A-Za-z]*"


validateParser : OptionsParser.OptionsParser GreetOptions Cli.OptionsParser.BuilderState.AnyOptions
validateParser =
    OptionsParser.build GreetOptions
        |> with
            (Option.requiredKeywordArg "name"
                |> Option.validate (Cli.Validate.regex capitalizedNameRegex)
            )
        |> with
            (Option.optionalKeywordArg "age"
                |> Option.validateMapIfPresent String.toInt
            )


type alias GreetOptions =
    { name : String
    , maybeAge : Maybe Int
    }


init : GreetOptions -> Cmd Never
init { name, maybeAge } =
    maybeAge
        |> Maybe.map (\age -> name ++ " is " ++ toString age ++ " years old")
        |> Maybe.withDefault ("Hello " ++ name ++ "!")
        |> Ports.print


dummy : Decoder String
dummy =
    Json.Decode.string


main : Program.StatelessProgram Never
main =
    Program.stateless
        { printAndExitFailure = Ports.printAndExitFailure
        , printAndExitSuccess = Ports.printAndExitSuccess
        , init = init
        , config = programConfig
        }