||| Module    : Main.idr
||| Copyright : (c) CONTRIBUTORS.md
||| License   : see LICENSE
|||
||| Borrowed From Idris2 and improved with Test.Unit
module Main

import Data.List

import Test.Golden

%default total

covering
main : IO ()
main
  = runner [ !(testsInDir "start-stop-help" "Top level REPL interactions")
           , !(testsInDir "game-start-stop" "Starting Stopping Games")
           , !(testsInDir "game-play-valid" "Playing Games Correctly")
           , !(testsInDir "game-play-valid-in" "Playing Games Incorrectly")
           , !(testsInDir "game-play-winning" "Playing Games to Completion")
           ]




-- [ EOF ]
