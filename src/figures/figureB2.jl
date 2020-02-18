""" This file builds the depletion manuscript, Figure B2, ITP Model Information. """

function plotActualvFit()
    (odf, effects, btp_std) = CVResults("ITP")
    pl = plot(odf[!, :Y], odf[!, :Fitted], seriestype=:scatter, smooth = true, legend = false)
    xlabel!(pl, "Actual effect")
    ylabel!(pl, "Fitted effect")
    title!(pl, "Actual effect vs fitted effect for ITP")
    return pl
end

function plotActualvPredict()
    (odf, effects, btp_std) = CVResults("ITP")
    pl = plot(odf[!, :Y], odf[!, :LOOPredict], seriestype=:scatter, smooth = true, legend = false)
    xlabel!(pl, "Actual effect")
    ylabel!(pl, "LOO predicted effect")
    title!(pl, "Actual effect vs LOO predicted for ITP")
    return pl
end

function plotCellTypeEffects()
    dataType = "ITP"
    ## blood data has different concentration and can't use this
    (odf, effects, btp_std) = CVResults("ITP")
    wtLineNo = odf[!, :Background] .== "wt"
    IgGcategory = odf[wtLineNo, :Condition]
    itemName = [String(i) * "_" * String(c) for c in cellTypes for i in IgGcategory]
    values = effects[wtLineNo, :]
    stdevs = btp_std[wtLineNo, :]

    pl = bar(itemName, vec(values), xrotation=40, yerr = vec(stdevs))
    title!(pl, "Weights of IgGx + celltype in wt for ITP")
    return pl
end

function figureB2()
    p1 = plotActualvFit()
    p2 = plotActualvPredict()
    p3 = plotCellTypeEffects()
    p = plot(p1, p2, p3, p3, layout = (2, 2), size = (1200, 1200), dpi = 300)
    savefig(p, "figureB2.pdf")
end
