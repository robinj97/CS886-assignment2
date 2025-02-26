module Main

import Data.String
import System.REPL


import State
import Command


helpStr : String
helpStr = "Help Me!"

export
process : (st  : State)
       -> (str : String)
              -> Maybe (String, State)
process st str with (Command.fromString str)
  process st str | Nothing
    = Nothing

  process st str | (Just Quit)
    = if inGame st
      then Just ("Already in Game, quitting game instead.\n", resetState st)
      else Nothing

  process st str | (Just Help)
    = Just ("\{helpStr}\n", st)

export
main : IO ()
main
  = replWith defaultState "> " process


-- [ EOF ]
