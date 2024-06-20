
module MyPlots

using AlgebraOfGraphics, CairoMakie
using DataFrames, DataFramesMeta
using CategoricalArrays


function errorbars(d::DataFrame, y::Symbol, x::Symbol; kwargs...)
    groupingvars = [x; [v for v in values(kwargs)]...]
    pdat = @chain d begin
        groupby(groupingvars)
        @combine begin
            :o = mean_and_std($y)
            :n = length($y)
        end
        @rtransform :m = first(:o)
        @rtransform :sem = last(:o) / sqrt(:n)
    end
    plt = data(pdat) * mapping(x, :m, :sem; kwargs...) * 
    (visual(Errorbars) + visual(Scatter))
    draw(plt)
end

function boxplot_jitter(d::AbstractDataFrame, y::Symbol, x::Symbol; return_plt=false, kwargs = ())
    #@show kwargs
    if !(d[:,x] isa CategoricalVector)
        d2 = @transform d $x = categorical($x)
    else
        d2 = d
    end
    jitter(v) = (x -> levelcode(x)+randn()*v)
    plt = data(d2) * (mapping(x => jitter(.1), y; kwargs...) * visual(Scatter, markersize=8,) +
                      mapping(x, y; kwargs...) * visual(BoxPlot, show_outliers=false, alpha=.3))
    if return_plt 
        return plt
    else
        return draw(plt)
    end
end

function boxplot_jitter(d::AbstractDataFrame, y::Symbol, x::Vector{Symbol}; return_plt=false, kwargs = ())
    #@show kwargs
    l = length(x)
    #int = Symbol(string(x[1]) * "_x_" * string(x[2]))
    int = prod([string(xi) * "_x_" for xi in x])[1:end-3]
    d2 = deepcopy(d)
    d2[:, int] .= ""
    d2[:, int] = [prod([string.(d[i, xi]) .* " x " for xi in x])[1:end-3]
                  for i in 1:nrow(d2)]
    @transform! d2 $int = categorical($int)
    jitter(v) = (x -> levelcode(x)+randn()*v)
    plt = data(d2) * (mapping(int => jitter(.1), y; kwargs...) * visual(Scatter, markersize=8,) +
                      mapping(int, y; kwargs...) * visual(BoxPlot, show_outliers=false, alpha=.3))
    if return_plt
        plt
    else
        draw(plt, axis=(xticklabelrotation=pi/4,))
    end
end

mytheme = Theme(
    Axis = (
        backgroundcolor = :gray95,
        leftspinevisible = false,
        rightspinevisible = false,
        bottomspinevisible = false,
        topspinevisible = false,
        xgridcolor = :gray95,
        ygridcolor = :gray95,
        xticklabelrotation = pi/4,
    )
)




# using PDFmerger
# # Usage:
# # df = (x=rand(500), y=rand(500), l=rand(["a", "b", "c", "d", "e", "f", "g", "h"], 500))
# # plt = data(df) * mapping(:x, :y, layout=:l)
# # pag = paginate(plt, layout = 1)
# function multipageplot(pag)
#     for i in 1:length(pag)
#         save("temp.pdf", draw(pag,i))
#         append_pdf!("allplots.pdf", "temp.pdf", cleanup=true)
#     end
# end


## can use this to make one large layout variable
#@rtransform df :l = join([:l1,:l2], "_")


export errorbars, boxplot_jitter, multipageplot

end
