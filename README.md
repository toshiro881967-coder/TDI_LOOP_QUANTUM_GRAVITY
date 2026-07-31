# TDI Loop Quantum Gravity — Formal Verification

[![Lean 4](https://img.shields.io/badge/Lean-4-blue)](https://leanprover.github.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Formal verification of Loop Quantum Gravity (LQG), Spin-Foam amplitudes, matter coupling, and corrections to the Bekenstein-Hawking area formula using **Lean 4**. 

This project translates advanced theoretical concepts from gravitational physics (such as constraints from gravitational wave data and classical $F(R)$ gravity) into fully checked, machine-verified mathematical proofs.

---

## 📂 Project Structure

* `Main.lean`: Entry point for executing the verification suite.
* `TdiProject/`: Core modules containing algebraic structures, gauge groups, and quantum dynamics definitions.
  * `MatterSpinFoamAmplitudes.lean`: Formalization of Spin-Foam vertex amplitudes coupled with boundary fermions and extended gauge symmetries ($SU(3) \times SU(2) \times U(1)$).
* `lakefile.toml`: Build configuration and dependencies managed via Lake.

---

## 🚀 Current Status & Features

* **Rigorous Verification:** Core theorems are verified with **zero `sorry` assumptions** in the Lean 4 kernel.
* **Hamiltonian & Gauge Constraints:** Formal proof of the Total Hamiltonian Constraint ($\hat{H}_{tot} |\psi\rangle = 0$) and local gauge charge conservation.

*(This section will be updated incrementally as new theoretical extensions and modules are added).*

---

## 🛠️ Prerequisites & Installation

To build and run this project, you need to have **Lean 4** and its build system **Lake** installed via `elan` (the Lean version manager).

1. Install `elan` (if you haven't already):
   ```bash
   curl [https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh](https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh) -sSf | sh