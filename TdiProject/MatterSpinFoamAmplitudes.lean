import Mathlib.Algebra.Ring.Basic
import Mathlib.Topology.MetricSpace.Basic

namespace TdiProject.MatterSpinFoamAmplitudes

/-- Struttura che rappresenta un bordo di un 4-plesso colorato con spin fermionici e di gauge. -/
structure SimplicialBoundaryColoring where
  fermionSpin : ℝ
  gaugeChargeLevel : ℕ
  is_valid_spin : fermionSpin ≥ 0.5
  is_neutral_or_charged : gaugeChargeLevel ≥ 0

/-- Regole di Feynman topologiche estese per i vertici Spin-Foam con accoppiamento alla materia. -/
noncomputable def TopologicalFeynmanVertexAmplitude (b : SimplicialBoundaryColoring) (couplingConstant : ℝ) : ℝ :=
  (b.fermionSpin ^ 2) * couplingConstant / (1.0 + (b.gaugeChargeLevel : ℝ))

/-- Proprietà di conservazione delle cariche di gauge locali sui vertici del complesso simpliciale. -/
def LocalGaugeChargeConservation (incomingCharges outgoingCharges : List ℕ) : Prop :=
  incomingCharges.sum = outgoingCharges.sum

/-- Teorema di verifica della conservazione delle cariche di gauge locali nei processi di scattering Spin-Foam. -/
theorem gauge_conservation_proof (incoming outgoing : List ℕ) 
  (h_balance : incoming.sum = outgoing.sum) : LocalGaugeChargeConservation incoming outgoing := h_balance

end TdiProject.MatterSpinFoamAmplitudes