import Mathlib.Analysis.SpecialFunctions.Pow.Real

namespace TdiProject.Basic

/-- Costante della Lunghezza di Planck ℓ_P -/
noncomputable def PlanckLength : Real := 1.616255e-35

/-- Area di Planck ℓ_P^2 -/
noncomputable def PlanckArea : Real := PlanckLength ^ 2

/-- Volume di Planck ℓ_P^3 -/
noncomputable def PlanckVolume : Real := PlanckLength ^ 3

/-- Parametro di Immirzi γ (valore standard ~0.2375) -/
noncomputable def ImmirziParameter : Real := 0.237539

end TdiProject.Basic