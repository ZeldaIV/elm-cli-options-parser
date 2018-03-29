module CommandTests exposing (all)

import Command
import Expect exposing (Expectation)
import Test exposing (..)


type Msg
    = Help
    | Version
    | OpenUrl String
    | OpenUrlWithFlag String Bool
    | Name String
    | FullName String String


all : Test
all =
    describe "CLI options parser"
        [ test "help command" <|
            \() ->
                Command.tryMatch [ "--help" ] (Command.build Help |> Command.expectFlag "help")
                    |> Expect.equal (Just Help)
        , test "version command" <|
            \() ->
                Command.tryMatch [ "--version" ] (Command.build Version |> Command.expectFlag "version")
                    |> Expect.equal (Just Version)
        , test "matching non-first element in list" <|
            \() ->
                Command.tryMatch [ "unused", "--version" ] (Command.build Version |> Command.expectFlag "version")
                    |> Expect.equal Nothing
        , test "command with args" <|
            \() ->
                Command.tryMatch [ "http://my-domain.com" ] (Command.build OpenUrl |> Command.expectOperand "url")
                    |> Expect.equal (Just (OpenUrl "http://my-domain.com"))
        , test "detects that optional flag is absent" <|
            \() ->
                Command.tryMatch [ "http://my-domain.com" ] (Command.build OpenUrlWithFlag |> Command.expectOperand "url" |> Command.withFlag "p")
                    |> Expect.equal (Just (OpenUrlWithFlag "http://my-domain.com" False))
        , test "detects that optional flag is present" <|
            \() ->
                Command.tryMatch [ "http://my-domain.com", "--p" ] (Command.build OpenUrlWithFlag |> Command.expectOperand "url" |> Command.withFlag "p")
                    |> Expect.equal (Just (OpenUrlWithFlag "http://my-domain.com" True))
        , test "non-matching option" <|
            \() ->
                Command.tryMatch [ "--version" ] (Command.build Help |> Command.expectFlag "help")
                    |> Expect.equal Nothing
        , test "option with argument" <|
            \() ->
                Command.tryMatch [ "--name", "Deanna" ] (Command.build Name |> Command.optionWithStringArg "name")
                    |> Expect.equal (Just (Name "Deanna"))
        , test "option with multiple required string arguments" <|
            \() ->
                Command.tryMatch
                    [ "--last-name"
                    , "Troi"
                    , "--first-name"
                    , "Deanna"
                    ]
                    (Command.build FullName
                        |> Command.optionWithStringArg "first-name"
                        |> Command.optionWithStringArg "last-name"
                    )
                    |> Expect.equal (Just (FullName "Deanna" "Troi"))
        , test "synopsis prints options with arguments" <|
            \() ->
                (Command.build FullName
                    |> Command.optionWithStringArg "first-name"
                    |> Command.optionWithStringArg "last-name"
                )
                    |> Command.synopsis "greet"
                    |> Expect.equal "greet --first-name <first-name> --last-name <last-name>"
        , test "print synopsis with required flag" <|
            \() ->
                Command.build Version
                    |> Command.expectFlag "version"
                    |> Command.synopsis "greet"
                    |> Expect.equal "greet --version"
        , test "recognizes empty operands and flags" <|
            \() ->
                []
                    |> Command.flagsAndOperands
                        (Command.build FullName
                            |> Command.optionWithStringArg "first-name"
                            |> Command.optionWithStringArg "last-name"
                        )
                    |> Expect.equal { flags = [], operands = [] }
        , test "gets operand from the front" <|
            \() ->
                [ "operand", "--verbose", "--dry-run" ]
                    |> Command.flagsAndOperands
                        (Command.build (,,)
                            |> Command.expectFlag "verbose"
                            |> Command.expectFlag "dry-run"
                        )
                    |> Expect.equal
                        { flags = [ "--verbose", "--dry-run" ]
                        , operands = [ "operand" ]
                        }
        , test "gets operand from the back" <|
            \() ->
                [ "--verbose", "--dry-run", "operand" ]
                    |> Command.flagsAndOperands
                        (Command.build (,,)
                            |> Command.expectFlag "verbose"
                            |> Command.expectFlag "dry-run"
                        )
                    |> Expect.equal
                        { flags = [ "--verbose", "--dry-run" ]
                        , operands = [ "operand" ]
                        }
        , test "gets operand from the front when args are used" <|
            \() ->
                [ "operand", "--first-name", "Will", "--last-name", "Riker" ]
                    |> Command.flagsAndOperands
                        (Command.build FullName
                            |> Command.optionWithStringArg "first-name"
                            |> Command.optionWithStringArg "last-name"
                        )
                    |> Expect.equal
                        { flags = [ "--first-name", "Will", "--last-name", "Riker" ]
                        , operands = [ "operand" ]
                        }
        , test "gets operand from the back when args are present" <|
            \() ->
                [ "--first-name", "Will", "--last-name", "Riker", "operand" ]
                    |> Command.flagsAndOperands
                        (Command.build FullName
                            |> Command.optionWithStringArg "first-name"
                            |> Command.optionWithStringArg "last-name"
                        )
                    |> Expect.equal
                        { flags = [ "--first-name", "Will", "--last-name", "Riker" ]
                        , operands = [ "operand" ]
                        }
        , test "gets operand when there are no options" <|
            \() ->
                [ "operand" ]
                    |> Command.flagsAndOperands
                        (Command.build identity
                            |> Command.expectOperand "foo"
                        )
                    |> Expect.equal
                        { flags = []
                        , operands = [ "operand" ]
                        }
        , test "doesn't match if operands are present when none are expected" <|
            \() ->
                Command.tryMatch
                    [ "--last-name"
                    , "Troi"
                    , "--first-name"
                    , "Deanna"
                    , "unexpectedOperand"
                    ]
                    (Command.build FullName
                        |> Command.optionWithStringArg "first-name"
                        |> Command.optionWithStringArg "last-name"
                    )
                    |> Expect.equal Nothing

        -- |> Expect.equal "greet -n <name> [-l][-a][-c option_argument][operand...]"
        ]