import Mathlib.Data.Real.Basic
import Mathlib.Data.Fintype.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace TdiProject.QuantumPolyhedra

-- Definizione astratta delle rappresentazioni di SU(2) associate ai link (label j)
structure SpinLink where
  label : ℕ  -- Rappresentazione di spin j (o 2j intero)
  deriving Repr

-- Condizione di chiusura classica di Kapovich-Millson (somma dei vettori di flusso = 0 in ℝ³)
def ClosureCondition {n : ℕ} (vectors : Fin n → ℝ × ℝ × ℝ) : Prop :=
  (Finset.univ.sum (fun i => (vectors i).1) = 0) ∧
  (Finset.univ.sum (fun i => (vectors i).2.1) = 0) ∧
  (Finset.univ.sum (fun i => (vectors i).2.2) = 0)

-- Spazio degli Intertwiner SU(2) per N-nodi
structure IntertwinerSpace (n : ℕ) (spins : Fin n → ℕ) where
  dim : ℕ
  is_non_trivial : dim > 0

end TdiProject.QuantumPolyhedra