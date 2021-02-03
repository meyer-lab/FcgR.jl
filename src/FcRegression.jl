module FcRegression
using LinearAlgebra
import Distances
using polyBindingModel
using Optim
using DataFrames
using Dierckx

include("figures/figureCommon.jl")

include("fcBindingModel.jl")
include("dataHelpers.jl")
include("mixture.jl")
include("regression.jl")
include("synergy.jl")
include("ExtraFunctions")

include("figures/figureW.jl")

include("figures/figure1.jl")
include("figures/figure2.jl")
include("figures/figure3.jl")
include("figures/figure4.jl")
include("figures/figureS1.jl")
include("figures/figureS2.jl")


function figureAll()
    setGadflyTheme()

    figure1()
    figure2()
    figure3()
    figure4()

    figureS1()
    figureS2()
end

export polyfc, polyfc_ActV

end # module
