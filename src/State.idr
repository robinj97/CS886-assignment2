module State

public export
data GameState = GameOn | GameOff

{-
   You will need to add your own state here
-}
public export
record State where
  constructor St
  gstate : GameState

export
defaultState : State
defaultState
  = (St GameOff)

export
resetState : State -> State
resetState _
  = (St GameOff)

export
inGame : State -> Bool
inGame (St GameOn)
  = True
inGame _
  = False

-- [ EOF ]
