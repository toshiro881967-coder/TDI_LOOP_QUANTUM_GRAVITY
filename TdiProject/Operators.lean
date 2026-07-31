import TdiProject.Basic
import TdiProject.SpinNetwork
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

namespace TdiProject.Operators

open TdiProject.Basic
open TdiProject.SpinNetwork

/-- Autovalore dell'operatore di Area per uno spigolo con spin j:
    A = 8π γ ℓ_P^2 √ (j(j + 1))
-/
noncomputable def AreaEigenvalue (s : Spin) : Real :=
  let j := (s.two_j : Real) / 2.0
  8.0 * Real.pi * ImmirziParameter * PlanckArea * Real.sqrt (j * (j + 1.0))

/-- Autovalore approssimato dell'operatore di Volume per un nodo v -/
noncomputable def VolumeEigenvalue (v : Node) (total_j : Real) : Real :=
  (v.valence : Real) * PlanckVolume * Real.sqrt total_j

/-- Simulazione dell'operatore di Olonomia h_γ(A) lungo un ciclo chiuso (Placchetta) -/
structure HolonomyOperator where
  loop_edge : Edge
  trace_value : Real

end TdiProject.Operators