module Command

import Decidable.Equality
import Data.String

import Extra

{-

You will need to add your commands here

-}
public export
data CMD = Quit
         | Help
         | Start
         | Stop



{-
And here
-}
export
fromString : String -> Maybe CMD
fromString str with (words str)
  fromString str | xs with (validShape xs)
    fromString str | [cmd] | (Yes Null) with (cmd)
      fromString str | [cmd] | (Yes Null) | ":help"
        = Just Help
      fromString str | [cmd] | (Yes Null) | ":quit"
        = Just Quit
      fromString str | [cmd] | (Yes Null) | ":start"
        = Just Start
      fromString str | [cmd] | (Yes Null) | ":stop"
        = Just Stop
      fromString str | [cmd] | (Yes Null) | rest
        = Nothing

    fromString str | [cmd, a] | (Yes Unary)
      = Nothing

    fromString str | [cmd, a, b] | (Yes Binary)
      = Nothing


    fromString str | [cmd, a, b, c] | (Yes Ternary) = Nothing

    fromString str | xs | (No contra)
      = Nothing

--  [ EOF ]
