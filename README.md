# TDI Loop Quantum Gravity — Formal Verification

[![Lean 4](https://img.shields.io/badge/Lean-4-blue)](https://leanprover.github.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Formal verification of Loop Quantum Gravity (LQG), Spin-Foam amplitudes, matter coupling ($SU(3) \times SU(2) \times U(1)$), quantum polyhedra geometry, unimodular LQC, inflation models, and topological path invariants using **Lean 4**[cite: 21].

---

## 📂 Project Structure

* `Main.lean`: Entry point for executing the verification suite and outputting the DST-Vault verification report.
* `TdiProject/`: Core modules containing algebraic structures, gauge groups, and quantum dynamics definitions.
  * `Basic.lean`: Foundational topological chains and inductive path structures[cite: 22].
  * `MatterSpinFoamAmplitudes.lean`: Formalization of Spin-Foam vertex amplitudes coupled with boundary fermions and extended gauge symmetries ($SU(3) \times SU(2) \times U(1)$)[cite: 21, 22].
  * `QuantumPolyhedra.lean`: Formalization of quantum polyhedra geometry, Kapovich-Millson closure constraints, and $SU(2)$ intertwiner spaces (collaborative framework with Fabio Anzà)[cite: 21, 22].
  * `OpenAspectsLimitations.lean`: Analysis of open aspects, semiclassical limits, and constraints[cite: 22].
* `lakefile.toml` / `lakefile.lean`: Build configuration and dependencies managed via Lake[cite: 22].

---

## 🚀 Current Status & Features

* **Rigorous Verification:** Core theorems are verified with **zero `sorry` assumptions** in the Lean 4 kernel[cite: 21, 22].
* **Hamiltonian & Gauge Constraints:** Formal proof of the Total Hamiltonian Constraint ($\hat{H}_{tot} |\psi\rangle = 0$) and local gauge charge conservation[cite: 21].
* **Unimodular LQC & Inflation:** Integration of unimodular time, singularity resolution via Big Bounce, and inflationary models (Starobinsky & $\alpha$-attractor)[cite: 21].
* **Quantum Polyhedra & Spin-Networks:** Integration of Kapovich-Millson phase space conditions, Bianchi-Donà-Speziale flux/area frameworks, and $SU(2)$ intertwiner convex geometry[cite: 21, 22].

---

## 🛠️ Build & Run Instructions

To compile and execute the formal verification suite locally:

1. Ensure you have **Lean 4** and **Lake** installed via `elan`:
   ```bash
   curl [https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh](https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh) -sSf | sh