using DrWatson
quickactivate(@__DIR__)
using BenchmarkTools, ProgressMeter, Printf, Dates, Pkg, Latexify
import DataFrames: DataFrame

max_day = 21

for day = 1:max_day
    include(@sprintf("day_%02d/main.jl", day))
end

pkg"precompile"

formatTime(t) = (1e9 * t) |> BenchmarkTools.prettytime

new_df() = DataFrame(part1_time = String[], part2_time = String[], part1_memory = String[], part2_memory = String[])
function benchmarkAll(; onlyOnce = false)
    df = new_df()
    for day = 1:max_day
        @info "benchmarking day" day
        module_name = Symbol(@sprintf("Day%02d", day))
        !isdefined(@__MODULE__, module_name) && continue
        benchmark(day=day, df=df, onlyOnce=onlyOnce)
    end
    show(df, summary=false, eltypes=false, rowlabel=:Day)
    df
end

function benchmark(; day::Int = min(Dates.day(Dates.today()), 25), df = new_df(), onlyOnce = false)
    module_name = Symbol(@sprintf("Day%02d", day))
    m = getproperty(@__MODULE__, module_name)
    t1 = onlyOnce ? @elapsed(m.part1()) : @benchmark($m.part1())
    t2 = onlyOnce ? @elapsed(m.part2()) : @benchmark($m.part2())
    if onlyOnce
        push!(df, [formatTime.((t1, t2))..., "-", "-"])
    else
        push!(df, [BenchmarkTools.prettytime.(time.((t1, t2)))...,  BenchmarkTools.prettymemory.(memory.((t1, t2)))...])
    end
    df
end

df = benchmarkAll()

println()
print(latexify(df, env=:mdtable, latex=false, side=1:max_day))
a_day = 21
df = benchmark(day=a_day)
println()
print(latexify(df, env=:mdtable, latex=false, side=a_day))

# code for generating markdown from loading_data.jl
# using Literate
# Literate.markdown("loading_data.jl", ".", execute=true)

# # benchmark of my bits2num implementations
# bits2num1(arr::BitArray) = sum(arr .* 2 .^ (length(arr)-1:-1:0))
# bits2num1(arr::SubArray{T,U,BitVector}) where {T,U} = sum(arr .* 2 .^ (length(arr)-1:-1:0))
# bits2num1(arr::Bool) = Int(arr)

# bits2num2(arr::BitArray) = reduce((x,y)->x*2+y, arr)
# bits2num2(arr::SubArray{T,U,BitVector}) where {T,U} = reduce((x,y)->x*2+y, arr)
# bits2num2(arr::Bool) = Int(arr)

# arr = BitVector([1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1])
# @btime bits2num1(arr)
# @btime bits2num2(arr)
# @btime bits2num1(arr[1:10])
# @btime bits2num2(arr[1:10])
# @btime bits2num1(@view(arr[1:10]))
# @btime bits2num2(@view(arr[1:10]))
# arr = BitVector([1,1,0,1])
# @btime bits2num1(arr)
# @btime bits2num2(arr)
# arr = true
# @btime bits2num1(arr)
# @btime bits2num2(arr)
# arr = BitVector([ones(Int,100); zeros(Int,100)])
# @btime bits2num1(arr)
# @btime bits2num2(arr)
# @btime bits2num1(arr[1:2:100])
# @btime bits2num2(arr[1:2:100])
# @btime bits2num1(@view(arr[1:2:100]))
# @btime bits2num2(@view(arr[1:2:100]))
# arr = trues(60)
# @btime bits2num1(arr)
# @btime bits2num2(arr)
# arr = falses(60)
# @btime bits2num1(arr)
# @btime bits2num2(arr)
