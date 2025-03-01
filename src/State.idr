module State
import Data.Vect

public export
data GameState = GameOn | GameOff

public export
data Piece = Clown | Joker | Empty

public export
data Player = P1 | P2


export
Eq Player where
  P1 == P1 = True
  P2 == P2 = True
  _  == _  = False

public export
implementation Show Player where
  show P1 = "P1"
  show P2 = "P2"

public export
implementation Eq Piece where
  Clown == Clown = True
  Joker == Joker = True
  Empty == Empty = True
  _ == _ = False

public export
implementation Show Piece where
  show Clown = "C"
  show Joker = "J"
  show Empty = "-"
{-
   You will need to add your own state here
-}
public export
record State where
  constructor St
  gstate : GameState
  board : Vect 5 (Vect 5 Piece)
  currentPlayer : Player

export
defaultState : State
defaultState
  = (St GameOff (replicate 5 (replicate 5 Empty)) P1)

export
resetState : State -> State
resetState _
  = (St GameOff (replicate 5 (replicate 5 Empty)) P1)

export
inGame : State -> Bool
inGame (St GameOn _ _)
  = True
inGame _
  = False

export
initBoard : Vect 5 (Vect 5 Piece)
initBoard = updateAt 0 (updateAt 1 (\_=> Clown) . updateAt 3 (\_=> Clown)) $
            updateAt 4 (updateAt 1 (\_=> Joker) . updateAt 3 (\_=> Joker)) $
            replicate 5 (replicate 5 Empty)

export
startGame : State -> State
startGame _ = St GameOn initBoard P1

export renderBoard : Vect 5 (Vect 5 Piece) -> String
renderBoard board =
  "  0|1|2|3|4\n" ++
  renderRows 0 board
  where
    renderRowContents : Vect 5 Piece -> String
    renderRowContents rowPieces = concat $ intersperse "|" (map show rowPieces)

    renderRows : Nat -> Vect 5 (Vect 5 Piece) -> String
    renderRows 5 _ = ""
    renderRows rowIdx board =
      case natToFin rowIdx 5 of
        Nothing => ""
        Just rowIdxAsFin =>
          let currentRow = index rowIdxAsFin board in
            show rowIdx ++ "|" ++ renderRowContents (index rowIdxAsFin board) ++
            (if rowIdx < 4 then "\n"
            else "") ++ renderRows (S rowIdx) board

export
isValidDirection : String -> Bool
isValidDirection "left" = True
isValidDirection "right" = True
isValidDirection "up" = True
isValidDirection "down" = True
isValidDirection _ = False

{- //Logic for moving
1. Get the piece at the position (DONE)
2. Check if the piece is of the current player (DONE)
3. Get the new position (DONE)
5. Get piece at new position
6. Check if piece belongs to player (invalid move)
7. If not piece of same player then move piece (update board by swapping pieces and/or remove other player piece if attack)
8. Update the board
9. Change the player
10. Check if the game is over
11. If game is over then change the state to GameOff -}

-- getPiece needs to take in a board and coordinates and return the piece at that position
-- Maybe since the position might be out of bounds
-- Consider proof for this
export
getPiece: Vect 5 (Vect 5 Piece) -> Nat -> Nat -> Maybe Piece
getPiece board x y =
  case natToFin x 5 of
    Nothing => Nothing
    Just xFinVal =>
      case natToFin y 5 of
        Nothing => Nothing
        Just yFinVal => Just (index yFinVal (index xFinVal board))

export
isValidPieceToMove: Piece -> Player -> Bool
isValidPieceToMove Clown P1 = True
isValidPieceToMove Joker P2 = True
isValidPieceToMove _ _ = False

-- Nothing if the position is out of bounds (invalid move)
export
getNewPosition: Nat -> Nat -> String -> Maybe (Nat, Nat)
getNewPosition x y direction =
  case direction of
    "left" =>
      if x == 0
      then Nothing
      else Just (minus x 1, y)
    "right" =>
      if x == 4
      then Nothing
      else Just (plus x 1, y)
    "up" =>
      if y == 0
      then Nothing
      else Just (x, minus y 1)
    "down" =>
      if y == 4
      then Nothing
      else Just (x, plus y 1)
    _ => Nothing

-- Update board signature   board, x, y, newX, newY, piece --> board
export
updateBoard : Vect 5 (Vect 5 Piece) -> Nat -> Nat -> Nat -> Nat -> Piece -> Vect 5 (Vect 5 Piece)
updateBoard board x y newX newY piece =
  let oldBoardCleared = clearPosition board x y in
  setPosition oldBoardCleared newX newY piece

where
  clearPosition : Vect 5 (Vect 5 Piece) -> Nat -> Nat -> Vect 5 (Vect 5 Piece)
  clearPosition b x y =
    case natToFin x 5 of
      Nothing => b
      Just xFinVal => case natToFin y 5 of
        Nothing => b
        Just yFinVal => updateAt xFinVal (updateAt yFinVal (\_ => Empty)) b

  setPosition : Vect 5 (Vect 5 Piece) -> Nat -> Nat -> Piece -> Vect 5 (Vect 5 Piece)
  setPosition b x y p =
    case natToFin x 5 of
      Nothing => b
      Just xFinVal => case natToFin y 5 of
        Nothing => b
        Just yFinVal => updateAt xFinVal (updateAt yFinVal (\_ => p)) b

export canAttack: Piece -> Piece -> Bool
canAttack Clown Joker = True
canAttack Joker Clown = True
canAttack _ _ = False

export checkWinner: Vect 5 (Vect 5 Piece) -> Maybe Player
checkWinner board =
  let hasClowns = any (\row => any (== Clown) row) board
      hasJokers = any (\row => any (== Joker) row) board
  in
    if not hasClowns
      then Just P2
    else if not hasJokers
      then Just P1
    else Nothing
-- [ EOF ]
