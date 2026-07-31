import Mathlib.Data.Real.Basic

namespace TdiProject.SpinNetwork

/-- Tipi di dato per identificare nodi e spigoli -/
structure Node where
  id : Nat
  valence : Nat
  deriving DecidableEq, Repr

structure Edge where
  id : Nat
  source : Node
  target : Node
  deriving DecidableEq, Repr

/-- Spin j etichettato come semi-intero (es. 1 = 1/2, 2 = 1, 3 = 3/2) -/
structure Spin where
  two_j : Nat
  deriving DecidableEq, Repr

/-- Rappresentazione del Grafo dello Spin Network -/
structure SpinNetworkGraph where
  nodes : List Node
  edges : List Edge
  spin_assignment : Edge → Spin
  -- Vincolo di chiusura sui nodi (Gauss Constraint)
  gauss_verified : Bool

/-- Predicato: Nodo ad alta valenza (N > 4) -/
def is_higher_valence (n : Node) : Prop :=
  n.valence > 4

end TdiProject.SpinNetwork