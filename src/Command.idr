module Command

import Decidable.Equality
import Data.String
import State
import Extra

{-

You will need to add your commands here

-}
public export
data CMD = Quit
         | Help
         | Start
         | Stop
         | Move Nat Nat String



{-
And here
-}
export
fromString : String -> Maybe CMD
fromString str with (words str)
  fromString str | xs with (validShape xs)
    fromString str | [cmd] | (Yes Null) with (cmd)
      fromString str | [cmd] | (Yes Null) | ":help" = Just Help
      fromString str | [cmd] | (Yes Null) | ":quit" = Just Quit
      fromString str | [cmd] | (Yes Null) | ":start" = Just Start
      fromString str | [cmd] | (Yes Null) | ":stop" = Just Stop
      fromString str | [cmd] | (Yes Null) | _ = Nothing

    fromString str | [cmd, a] | (Yes Unary) = Nothing

    fromString str | [cmd, a, b] | (Yes Binary) = Nothing

    fromString str | [cmd, x, y, direction] | (Yes Ternary) with (cmd)
      fromString str | [":move", x, y, direction] | (Yes Ternary) | ":move" with (Nat.fromString x, Nat.fromString y)
        fromString str | [":move", x, y, direction] | (Yes Ternary) | ":move" | (Just parsedX, Just parsedY)
          = if isValidDirection direction
            then Just (Move parsedX parsedY direction)
            else Nothing
        fromString str | [":move", x, y, direction] | (Yes Ternary) | ":move" | _ = Nothing
      fromString str | [cmd, x, y, direction] | (Yes Ternary) | _ = Nothing

    fromString str | xs | (No contra) = Nothing

--  [ EOF ]
