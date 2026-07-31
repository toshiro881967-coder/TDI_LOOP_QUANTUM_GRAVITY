import TdiProject.Topology

set_option linter.style.docString false
set_option linter.style.whitespace false
set_option linter.style.longLine false
set_option linter.unusedVariables false

namespace TdiProject.Algebra

open TdiProject.Topology

structure DSTDualAlgebra (α β : Type) where
  to_dual   : α → β
  to_primal : β → α
  involution_primal : ∀ x : α, to_primal (to_dual x) = x

structure DSTDualState where
  dual_code : Nat
  deriving DecidableEq, Repr

def knot_to_dual (s : DSTKnotState) : DSTDualState := ⟨s.crossing_count⟩
def dual_to_knot (d : DSTDualState) : DSTKnotState := ⟨d.dual_code⟩

theorem dst_involution_proof (s : DSTKnotState) : dual_to_knot (knot_to_dual s) = s := by
  rfl

def dst_vault_algebra : DSTDualAlgebra DSTKnotState DSTDualState := {
  to_dual := knot_to_dual,
  to_primal := dual_to_knot,
  involution_primal := dst_involution_proof
}

def dual_bracket (d : DSTDualState) : LaurentPoly :=
  kauffman_bracket (dual_to_knot d)

def is_compromised (s : DSTKnotState) : Prop :=
  s.crossing_count > 100

theorem safety_invariant_theorem (s_valid s_bad : DSTKnotState)
    (h_valid : s_valid.crossing_count ≤ 14) (h_bad : is_compromised s_bad)
    (m : Move) (h_trans : is_valid_transition s_valid s_bad m) : False := by
  unfold is_valid_transition at h_trans
  unfold is_compromised at h_bad
  cases m <;> omega

end TdiProject.Algebra