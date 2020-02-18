module FcgR
using LinearAlgebra
using ForwardDiff
import Distances

include("fcBindingModel.jl")
include("dataHelpers.jl")
include("regression.jl")
include("synergy.jl")
include("translation.jl")

using Plots

include("figures/figure1.jl")
include("figures/figureB1.jl")
include("figures/figureB2.jl")
include("figures/figureW.jl")

export calculateIsobologram, polyfc, polyfc_ActV

end # module
