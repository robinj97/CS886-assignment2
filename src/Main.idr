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
makeMove : State -> Nat -> Nat -> String -> Maybe (String, State)
makeMove st x y direction =
  if not (inGame st)
  then Nothing
  else if x >= 5 || y >= 5
  then Nothing
  else
    -- Swap x and y when calling getPiece
    case getPiece (board st) y x of
      Nothing => Just ("Invalid position\n", st)
      Just Empty => Just ("You selected an empty cell.\n", st)  -- Clear message for empty cells
      Just piece =>
        if not (isValidPieceToMove piece (currentPlayer st))
          then
            -- Give a more specific error message based on the current player and piece
            case (currentPlayer st, piece) of
              (P1, Joker) => Just ("You cannot move jokers.\n", st)  -- More user-friendly
              (P2, Clown) => Just ("You cannot move clowns.\n", st)  -- More user-friendly
              _ => Just ("Invalid piece to move\n", st)  -- Fallback, shouldn't happen
        else
          -- Keep original x,y for getNewPosition since it uses your convention
          case getNewPosition x y direction of
            Nothing => Just ("Invalid move\n", st)
            Just (newX, newY) =>
              -- Swap newX and newY when calling getPiece
              case getPiece (board st) newY newX of
                Nothing => Just ("Invalid position\n", st)
                Just retrievedPiece =>
                  if retrievedPiece == Empty || canAttack piece retrievedPiece
                    then
                      -- Swap x,y and newX,newY when calling updateBoard
                      let newBoard = updateBoard (board st) y x newY newX piece
                          nextPlayer = case currentPlayer st of
                                        P1 => P2
                                        P2 => P1
                          -- Check for winner after move
                          winner = checkWinner newBoard
                          -- Set game state based on winner
                          gameState = case winner of
                                        Nothing => GameOn
                                        Just _ => GameOff
                          newState = St gameState newBoard nextPlayer
                          -- Create a move description message
                          moveMsg = "Moved (" ++ show x ++ ", " ++ show y ++ ") to (" ++ show newX ++ ", " ++ show newY ++ ")"
                      in
                        case winner of
                          Just winningPlayer =>
                            let winMsg = case winningPlayer of
                                           P1 => "Player 1 Wins"
                                           P2 => "Player 2 Wins"
                            in Just (winMsg, newState)
                          Nothing =>
                            Just (moveMsg, newState)
                  else
                    -- Give more specific error for invalid attacks
                    case (piece, retrievedPiece) of
                      (Clown, Clown) => Just ("Clowns cannot attack clowns!\n", st)  -- More user-friendly
                      (Joker, Joker) => Just ("Jokers cannot attack jokers!\n", st)  -- More user-friendly
                      _ => Just ("Invalid move\n", st)  -- Fallback, shouldn't happen

export
process : (st  : State)
       -> (str : String)
              -> Maybe (String, State)
process st str with (Command.fromString str)
  process st str | Nothing
    = Just ("Invalid Command.\n", st)

  process st str | (Just Quit)
    = if inGame st
      then Just ("Already in Game, quitting game instead.\n", resetState st)
      else Nothing
  process st str | (Just Help)
    = Just ("\{helpStr}\n", st)

  process st str | (Just Start)
  = if inGame st
    then Just ("Game has already started and is ongoing.\n", st)
    else
      let startedState = startGame st in
        Just ("Starting Game\n\n\{renderBoard (board startedState)}\n\n\{show (currentPlayer startedState)}", startedState)
  process st str | (Just Stop)
    = if inGame st
      then Just ("Stopping Game\n", resetState st)
      else Just ("Game has not started yet.\n", st)

  process st str | (Just (Move x y direction))
  = case makeMove st x y direction of
      Nothing => Just ("Invalid Move\n", st)
      Just (message, newState) =>
        if isPrefixOf "Moved" message
        then
          -- Include the next player indicator as part of the output
          let nextPlayerPrefix = show (currentPlayer newState)
          in Just ("\{renderBoard (board newState)}\n\n\{message}\n\{nextPlayerPrefix}", newState)
        else if message == "Player 1 Wins" || message == "Player 2 Wins"
        then
          -- For win messages, display the board first, then the win message
          Just ("\{renderBoard (board newState)}\n\n\{message}\n", newState)
        else
          -- For error messages, add a newline and the current player
          Just (message ++ "\n\{show (currentPlayer st)}", st)

export
main : IO ()
main = replWith defaultState "> " process


-- [ EOF ]
