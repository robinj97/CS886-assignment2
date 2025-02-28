module State
import Data.Vect

public export
data GameState = GameOn | GameOff

public export
data Piece = Clown | Joker | Empty

public export
data Player = P1 | P2

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

-- [ EOF ]
