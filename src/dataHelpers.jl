"""
Guidance on DataFrame handling:
1. First thing first: DataFrame is different from Matrix!
2. All saved .csv files must be a valid dataframe (explained below) when
    imported by a one-line read command (delim = ',', comment = "#", etc.)
3. No two columns shall bear the same name (especially in csv files)
4. Keep the row indices (1,2,3,...) auto-generated by the import function
5. Use long format to store those with replicates
6. Use consistent name in all .csv files
    (e.g. never have both "FcgRI" and "FcgR1", even in different files)
7. Check/sort/reorder the order of rows and cols whenever that matters
"""

using DataFrames
using CSV

const KxConst = 6.31e-13 # 10^(-12.2)

function geocmean(x)
    x = convert(Vector, x)
    x[x .<= 1.0] .= 1.0
    return exp( sum(log.(x))/length(x) )
end

cellTypes = [:ncMO, :cMO, :NKs, :Neu, :EO]
murineFcgR = [:FcgRI, :FcgRIIB, :FcgRIII, :FcgRIV]
murineActI = [1, -1, 1, 1]

function importRtot(; murine=true)
    if murine
        df = CSV.read("../data/murine-FcgR-abundance.csv")
    else
        df = CSV.read("../data/human-FcgR-abundance.csv")
    end
    df = aggregate(df, [:Cells, :Receptor], geocmean)
    df = unstack(df, :Receptor, :Cells, :Count_geocmean)
    return convert(Matrix{Float64}, df[!, cellTypes])
end

"""Returns human FcgR expression matrix with a specific genotype"""
function genotype_expression(gtype="RTF")
    receps = Symbol.(["FcgRI", "FcgRIIA-131H", "FcgRIIA-131R", "FcgRIIB-232I", "FcgRIIB-232T", "FcgRIIC-13N", "FcgRIIIA-158V", "FcgRIIIA-158F", "FcgRIIIB"])
    df = DataFrame(transpose(importRtot(murine=false)))
    df_renamed = names!(df, Symbol.(["FcgRI", "FcgRIIA-131", "FcgRIIB-232", "FcgRIIC-13N", "FcgRIIIA-158", "FcgRIIIB"]))
    
    ### Apply Genotyping to Small Subset
    df_better = rename!(df_renamed, Symbol("FcgRIIA-131") => Symbol("FcgRIIA-131" * gtype[1]),
                                    Symbol("FcgRIIB-232") => Symbol("FcgRIIB-232" * gtype[2]),
                                    Symbol("FcgRIIIA-158") => Symbol("FcgRIIIA-158" * gtype[3]))
    
    ### Complete the Data Frame with all Receptors
    dict = Dict('H'=>'R', 'R'=>'H', 'I'=>'T', 'T'=>'I', 'V'=>'F', 'F'=>'V')
    anti_gtype = ["FcgRIIA-131" * dict[gtype[1]], "FcgRIIB-232" * dict[gtype[2]], "FcgRIIIA-158" * dict[gtype[3]]]
    df_better[Symbol.(anti_gtype)] = [1.0, 1.0, 1.0, 1.0, 1.0]
    
    ### Correctly Order Columns
    df_out = DataFrame()
    for i in receps
        df_out[i] = df_better[i]
    end
    return transpose(Matrix(df_out))
end


""" Import human or murine affinity data. """
function importKav(; murine=true, c1q=false)
    if murine
        df = CSV.read("../data/murine-affinities.csv", comment="#")
    else
        df = CSV.read("../data/human-affinities.csv", comment="#")
    end

    if c1q == false
        df = filter(row -> row[:FcgR] != "C1q", df)
    end

    df = melt(df; variable_name=:IgG, value_name=:Kav)
    df = unstack(df, :FcgR, :Kav)
    return df
end


""" Import cell depletion data. """
function importDepletion(dataType; c1q=false)
    if dataType == "ITP"
        filename = "../data/nimmerjahn-ITP.csv"
    elseif dataType == "blood"
        filename = "../data/nimmerjahn-CD20-blood.csv"
    elseif dataType == "bone"
        filename = "../data/nimmerjahn-CD20-bone.csv"
    elseif dataType == "melanoma"
        filename = "../data/nimmerjahn-melanoma.csv"
    else
        @error "Data type not found"
    end

    df = CSV.read(filename, delim=",", comment="#")
    df[!, :Condition] = map(Symbol, df[!, :Condition])

    affinityData = importKav(murine=true, c1q=c1q)
    df = join(df, affinityData, on = :Condition => :IgG, kind = :inner)

    df[df[:, :Background] .== "R1KO", :FcgRI] .= 0.0
    df[df[:, :Background] .== "R2KO", :FcgRIIB] .= 0.0
    df[df[:, :Background] .== "R3KO", :FcgRIII] .= 0.0
    df[df[:, :Background] .== "R1/3KO", [:FcgRI, :FcgRIII]] .= 0.0
    df[df[:, :Background] .== "R4block", :FcgRIV] .= 0.0
    df[df[:, :Background] .== "gcKO", [:FcgRI, :FcgRIIB, :FcgRIII, :FcgRIV]] .= 0.0
    return df
end
