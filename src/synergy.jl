
""" Calculates the isobologram between two IgGs under the defined conditions. """
function calculateIsobologram(IgGXidx, IgGYidx, valency, ICconc, FcExpr, Kav; quantity=nothing, actV=nothing, nPoints=33)
    @assert length(FcExpr) == size(Kav, 2)

    if actV != nothing
        quantity = "ActV"
        @assert length(actV) == length(FcExpr)
    elseif quantity == nothing
        quantity = "Lbound"
    end

    IgGYconc = range(0.0, stop=1.0, length=nPoints)
    output = zeros(length(IgGYconc))

    for idx in 1:length(IgGYconc)
        IgGC = zeros(size(Kav, 1))
        IgGC[IgGYidx] = IgGYconc[idx]
        IgGC[IgGXidx] = 1 - IgGYconc[idx]

        output[idx] = fcBindingModel.polyfc(ICconc, KxConst, valency, FcExpr, IgGC, Kav, actV)[quantity]
    end

    return output
end
