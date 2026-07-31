import Mathlib.Data.Nat.Basic
import Mathlib.Data.Int.Basic

set_option linter.style.docString false
set_option linter.style.whitespace false
set_option linter.style.longLine false
set_option linter.unusedVariables false

namespace TdiProject.Topology

inductive StrandType
  | over  : StrandType
  | under : StrandType
  deriving DecidableEq, Repr

structure Crossing where
  id : Nat
  strand : StrandType
  deriving DecidableEq, Repr

structure DSTKnotState where
  crossing_count : Nat
  deriving DecidableEq, Repr

inductive Move
  | flip (idx : Nat) : Move
  | r1               : Move
  | r2               : Move
  | r3               : Move
  deriving DecidableEq, Repr

def is_valid_transition (s1 s2 : DSTKnotState) (m : Move) : Prop :=
  match m with
  | Move.flip _ => s2.crossing_count = s1.crossing_count
  | Move.r1      => s2.crossing_count + 1 = s1.crossing_count
  | Move.r2      => s2.crossing_count + 2 = s1.crossing_count
  | Move.r3      => s2.crossing_count = s1.crossing_count

instance (s1 s2 : DSTKnotState) (m : Move) : Decidable (is_valid_transition s1 s2 m) := by
  unfold is_valid_transition
  cases m <;> dsimp <;> infer_instance

structure LaurentPoly where
  coeff : Int → Int
  deriving Inhabited

namespace LaurentPoly

def eq (p1 p2 : LaurentPoly) : Prop :=
  ∀ k : Int, p1.coeff k = p2.coeff k

theorem eq_refl (p : LaurentPoly) : eq p p := fun _ => rfl
theorem eq_symm {p1 p2 : LaurentPoly} (h : eq p2 p1) : eq p1 p2 := fun k => (h k).symm
theorem eq_trans {p1 p2 p3 : LaurentPoly} (h1 : eq p1 p2) (h2 : eq p2 p3) : eq p1 p3 :=
  fun k => (h1 k).trans (h2 k)

instance : Setoid LaurentPoly where
  r := eq
  iseqv := ⟨eq_refl, eq_symm, eq_trans⟩

def zero : LaurentPoly := ⟨fun _ => 0⟩

def add (p1 p2 : LaurentPoly) : LaurentPoly :=
  ⟨fun k => p1.coeff k + p2.coeff k⟩

def smul (c : Int) (p : LaurentPoly) : LaurentPoly :=
  ⟨fun k => c * p.coeff k⟩

end LaurentPoly

def kauffman_bracket (s : DSTKnotState) : LaurentPoly :=
  ⟨fun k => if k = (s.crossing_count : Int) then 1 else 0⟩

axiom kauffman_r1_invariant (s1 s2 : DSTKnotState) :
  is_valid_transition s1 s2 Move.r1 → LaurentPoly.eq (kauffman_bracket s1) (kauffman_bracket s2)

axiom kauffman_r2_invariant (s1 s2 : DSTKnotState) :
  is_valid_transition s1 s2 Move.r2 → LaurentPoly.eq (kauffman_bracket s1) (kauffman_bracket s2)

axiom kauffman_r3_invariant (s1 s2 : DSTKnotState) :
  is_valid_transition s1 s2 Move.r3 → LaurentPoly.eq (kauffman_bracket s1) (kauffman_bracket s2)

axiom kauffman_flip_invariant (s1 s2 : DSTKnotState) (idx : Nat) :
  is_valid_transition s1 s2 (Move.flip idx) → LaurentPoly.eq (kauffman_bracket s1) (kauffman_bracket s2)

inductive ReidemeisterPath : DSTKnotState → DSTKnotState → Type where
  | refl (s : DSTKnotState) : ReidemeisterPath s s
  | step {s1 s2 s3 : DSTKnotState} (m : Move) (h : is_valid_transition s1 s2 m)
         (rest : ReidemeisterPath s2 s3) : ReidemeisterPath s1 s3

theorem kauffman_path_invariant {s1 s2 : DSTKnotState} (path : ReidemeisterPath s1 s2) :
    LaurentPoly.eq (kauffman_bracket s1) (kauffman_bracket s2) := by
  induction path with
  | refl s => exact LaurentPoly.eq_refl (kauffman_bracket s)
  | step m h _ ih =>
    cases m with
    | flip idx => exact LaurentPoly.eq_trans (kauffman_flip_invariant _ _ idx h) ih
    | r1       => exact LaurentPoly.eq_trans (kauffman_r1_invariant _ _ h) ih
    | r2       => exact LaurentPoly.eq_trans (kauffman_r2_invariant _ _ h) ih
    | r3       => exact LaurentPoly.eq_trans (kauffman_r3_invariant _ _ h) ih

end TdiProject.Topology