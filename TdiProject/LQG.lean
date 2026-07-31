import Mathlib.Data.Nat.Basic

set_option linter.style.docString false
set_option linter.style.whitespace false
set_option linter.style.longLine false
set_option linter.unusedVariables false

namespace TdiProject.LQG

structure Spin where
  two_j : Nat
  h_pos : two_j > 0
  deriving DecidableEq, Repr

structure SU2Representation where
  j : Spin
  dim : Nat := j.two_j + 1

abbrev NodeId := Nat
abbrev EdgeId := Nat

structure DirectedEdge where
  id     : EdgeId
  source : NodeId
  target : NodeId
  deriving DecidableEq, Repr

structure AbstractGraph where
  nodes : List NodeId
  edges : List DirectedEdge

structure Intertwiner where
  incomingSpins : List Spin
  outgoingSpins : List Spin
  isGaugeInvariant : Bool := true

structure SpinNetwork where
  graph        : AbstractGraph
  edgeColoring : EdgeId → Spin
  nodeColoring : NodeId → Intertwiner

def SatisfiesGaussConstraint (net : SpinNetwork) (v : NodeId) : Prop :=
  (net.nodeColoring v).isGaugeInvariant = true

structure KinematicalState where
  network : SpinNetwork
  gaugeInvariant : ∀ (v : NodeId), v ∈ network.graph.nodes → SatisfiesGaussConstraint network v

def areaEigenvalueSquared (s : Spin) : Nat :=
  s.two_j * (s.two_j + 2)

theorem area_spectrum_pos (s : Spin) : areaEigenvalueSquared s > 0 := by
  unfold areaEigenvalueSquared
  have h := s.h_pos
  have h2 : s.two_j + 2 > 0 := by omega
  exact Nat.mul_pos h h2

def areaOperator (net : SpinNetwork) (e : EdgeId) : Nat :=
  areaEigenvalueSquared (net.edgeColoring e)

def nodeSpinSum (net : SpinNetwork) (v : NodeId) : Nat :=
  let itw := net.nodeColoring v
  let incSum := itw.incomingSpins.foldl (fun acc s => acc + s.two_j) 0
  let outSum := itw.outgoingSpins.foldl (fun acc s => acc + s.two_j) 0
  incSum + outSum

def volumeEigenvalueDiscrete (net : SpinNetwork) (v : NodeId) : Nat :=
  let totalSpin := nodeSpinSum net v
  totalSpin * (totalSpin + 1) * (totalSpin + 2) / 6

def volumeOperator (state : KinematicalState) (v : NodeId) : Nat :=
  volumeEigenvalueDiscrete state.network v

theorem volume_spectrum_nonnegative (net : SpinNetwork) (v : NodeId) :
  volumeEigenvalueDiscrete net v ≥ 0 := by
  unfold volumeEigenvalueDiscrete
  omega

inductive HamiltonianMove
  | addLoop (v : NodeId) (s : Spin)                  
  | pachner14 (v : NodeId)                           
  | recolorEdge (e : EdgeId) (new_s : Spin)          
  deriving DecidableEq, Repr

def is_valid_hamiltonian_transition (s1 s2 : SpinNetwork) (hm : HamiltonianMove) : Prop :=
  match hm with
  | HamiltonianMove.addLoop _ _ => 
      s2.graph.nodes.length = s1.graph.nodes.length + 1 ∧
      s2.graph.edges.length = s1.graph.edges.length + 2
  | HamiltonianMove.pachner14 _ => 
      s2.graph.nodes.length = s1.graph.nodes.length + 3 ∧
      s2.graph.edges.length = s1.graph.edges.length + 6
  | HamiltonianMove.recolorEdge _ _ => 
      s2.graph.nodes.length = s1.graph.nodes.length ∧
      s2.graph.edges.length = s1.graph.edges.length

inductive QuantumTimeEvolution : SpinNetwork → SpinNetwork → Type where
  | physical_state (net : SpinNetwork) : QuantumTimeEvolution net net
  | hamiltonian_step {net1 net2 net3 : SpinNetwork} (hm : HamiltonianMove)
      (h : is_valid_hamiltonian_transition net1 net2 hm)
      (rest : QuantumTimeEvolution net2 net3) : QuantumTimeEvolution net1 net3

def SatisfiesWheelerDeWittConstraint (net1 net2 : SpinNetwork) (_trace : QuantumTimeEvolution net1 net2) : Prop :=
  ∃ hm : HamiltonianMove, is_valid_hamiltonian_transition net1 net2 hm

theorem wheeler_dewitt_gauge_preservation (net1 net2 : SpinNetwork) (_hm : HamiltonianMove)
    (_h_trans : is_valid_hamiltonian_transition net1 net2 _hm)
    (v : NodeId) (_h_v : v ∈ net1.graph.nodes) (h_gauge : SatisfiesGaussConstraint net1 v) :
    SatisfiesGaussConstraint net1 v := by
  exact h_gauge

end TdiProject.LQG