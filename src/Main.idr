module Main

import Data.String
import System.REPL


import State
import Command


helpStr : String
helpStr = "Clowns & Jokers\n\nCommands:\n\n"
       ++ ":help             -- print this\n"
       ++ ":quit             -- Exit programme\n"
       ++ ":start            -- Start a game\n"
       ++ ":stop             -- Stop a running game\n"
       ++ ":move [x] [y] [d] -- move a piece at position (x,y) in direction `d`\n"
       ++ "                     where\n"
       ++ "                       x,y is a number  between 0 and 4\n"
       ++ "                       d is one of: left, right, up, down"

export
makeMove : State -> Nat -> Nat -> String -> Maybe State
makeMove st x y direction =
  if not (inGame st)
  then Nothing
  else if x >= 5 || y >= 5
  then Nothing
  else Just st

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

  process st str | (Just Start)
  = if inGame st
    then Just ("Game has already started and is ongoing.",st)
    else
      let startedState = startGame st in
        Just ("Starting Game\n\n\{renderBoard (board startedState)}\n\n\{show (currentPlayer startedState)}", startedState)
  process st str | (Just Stop)
    = if inGame st
      then Just ("Stopping Game\n", resetState st)
      else Just ("Game has not started yet.", st)

  process st str | (Just (Move x y direction))
    = case makeMove st x y direction of
        Nothing => Just ("Invalid move!", st)
        Just newState => Just ("Piece moved!", newState)

export
main : IO ()
main
  = replWith defaultState "> " process


-- [ EOF ]
