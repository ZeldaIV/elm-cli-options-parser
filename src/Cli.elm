module Cli exposing (MatchResult(..), helpText, try)

import Cli.Command as Command exposing (Command)
import Cli.Decode


type MatchResult msg
    = ValidationErrors (List Cli.Decode.ValidationError)
    | NoMatch (List String)
    | Match msg


try : List (Command msg) -> List String -> MatchResult msg
try commands argv =
    let
        matchResults =
            commands
                |> List.map
                    (argv
                        |> List.drop 2
                        |> Command.tryMatchNew
                    )

        commonUnmatchedFlags =
            case matchResults of
                [ Command.NoMatch unknownFlags ] ->
                    unknownFlags

                _ ->
                    []
    in
    matchResults
        |> List.map Command.matchResultToMaybe
        |> oneOf
        |> (\maybeResult ->
                case maybeResult of
                    Just result ->
                        case result of
                            Ok msg ->
                                Match msg

                            Err validationErrors ->
                                ValidationErrors validationErrors

                    Nothing ->
                        NoMatch commonUnmatchedFlags
           )


oneOf : List (Maybe a) -> Maybe a
oneOf =
    List.foldl
        (\x acc ->
            if acc /= Nothing then
                acc
            else
                x
        )
        Nothing


helpText : String -> List (Command msg) -> String
helpText programName commands =
    commands
        |> List.map (Command.synopsis programName)
        |> String.join "\n"