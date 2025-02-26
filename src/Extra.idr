||| Usefule extras that you may or may not need
|||
module Extra

import Decidable.Equality

import Data.String
import Data.Maybe

import Data.Vect
import Data.Fin
import Data.Fin.Order

namespace Fin

  export
  show : Fin n -> String
  show = (show . cast {to=Nat})


  public export
  data FinOneLess : (x,y : Fin k) -> Type
    where
      FOL : FinOneLess FZ (FS FZ)
      FO  : FinOneLess a b -> FinOneLess (FS a) (FS b)

  public export
  FinOneMore : (x,y : Fin k) -> Type
  FinOneMore x y = FinOneLess y x

  Uninhabited (FinOneLess FZ FZ) where
    uninhabited FOL impossible
    uninhabited (FO x) impossible

  Uninhabited (FinOneLess FZ (FS (FS u))) where
    uninhabited FOL impossible
    uninhabited (FO y) impossible

  Uninhabited (FinOneLess (FS u) FZ) where
    uninhabited FOL impossible
    uninhabited (FO x) impossible

  succVoif : (FinOneLess x_0 y_0 -> Void) -> FinOneLess (FS x_0) (FS y_0) -> Void
  succVoif f (FO x) = f x

  export
  isOneLess : (x,y : Fin k) -> Dec (FinOneLess x y)
  isOneLess FZ FZ
    = No absurd
  isOneLess FZ (FS FZ)
    = Yes FOL
  isOneLess FZ (FS (FS x))
    = No absurd
  isOneLess (FS x) FZ
    = No absurd
  isOneLess (FS x) (FS y) with (isOneLess x y)
    isOneLess (FS x) (FS y) | (Yes prf)
      = Yes (FO prf)
    isOneLess (FS x) (FS y) | (No contra)
      = No (succVoif contra)

namespace Nat
  export
  fromString : String -> Maybe Nat
  fromString = parsePositive {a=Nat}

namespace List

  public export
  data ValidShape : List String -> Type where
    Null : ValidShape [cmd]
    Unary : ValidShape [cmd,a]
    Binary : ValidShape [cmd,a,b]
    Ternary : ValidShape [cmd,a,b,c]

  Uninhabited (ValidShape []) where
    uninhabited Null impossible

  Uninhabited (ValidShape ((v::w::x::y::z::rest))) where
    uninhabited Null impossible


  export
  validShape : (xs : List String)
                  -> Dec (ValidShape xs)
  validShape []
    = No absurd
  validShape (v :: [])
    = Yes Null
  validShape (v :: (w :: []))
    = Yes Unary
  validShape (v :: (w :: (x :: [])))
    = Yes Binary
  validShape (w :: (x :: (y :: (z :: []))))
    = Yes Ternary
  validShape (v :: w :: (x :: (y :: (z :: xs))))
    = No absurd


-- [ EOF ]
