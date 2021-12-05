module Day05

using DrWatson
quickactivate(@__DIR__)
using OffsetArrays
# using TimerOutputs
# using BenchmarkTools
include(projectdir("misc.jl"))

# const to = TimerOutput()
# reset_timer!(to)

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")

parse_row(x) = split(x, " -> ") .|> (x->split(x, ",") .|> x->parse(Int32, x)) |> x->reduce(hcat, x)
is_axis_aligned(x::Matrix) = @inbounds x[1,1] == x[1,2] || x[2,1] == x[2,2]
process_data() = raw_data |> read_lines .|> parse_row

function assign2points_between!(grid, i)
    #= @timeit to "dif" =# @inbounds dif = i[:,2] - i[:,1]
    #= @timeit to "max_dif" =# max_dif = maximum(abs, dif)
    #= @timeit to "normed" =# normed_vec = dif .÷ max_dif
    #= @timeit to "point_list" =# for j in 0:max_dif
        @inbounds k, l = i[:,1].+normed_vec*j
        @inbounds grid[k, l] += 1
    end
end

# Analytic approach where I examine all unordered pairs (combinations of 2) and for intersecting lines I would
# list points, get that list of points and then change it to Set to get unique number of points and count it
# is doable, but because of thousands of points and relative small dimensions (1k x 1k) of the grid, the numeric approach is better.
function part1()
    #= @timeit to "process_data" =# data = process_data()
    #= @timeit to "ext1" =# min1, max1 = extrema(x->getindex(x, 1), data)
    #= @timeit to "ext2" =# min2, max2 = extrema(x->getindex(x, 2), data)
    #= @timeit to "ext3" =# min3, max3 = extrema(x->getindex(x, 3), data)
    #= @timeit to "ext4" =# min4, max4 = extrema(x->getindex(x, 4), data)
    #= @timeit to "max_x" =# max_x = max(max1, max3)
    #= @timeit to "min_x" =# min_x = min(min1, min3)
    #= @timeit to "max_y" =# max_y = max(max2, max4)
    #= @timeit to "min_y" =# min_y = min(min2, min4)
    #= @timeit to "grid" =# grid = OffsetArray(zeros(Int8, 1-min_x+max_x, 1-min_y+max_y), (min_x:max_x, min_y:max_y))
    #= @timeit to "axis_aligned" =# axis_aligned = filter(is_axis_aligned, data)
    # i = axis_aligned[1]
    
    #= @timeit to "all_lines" =# for i in axis_aligned
        assign2points_between!(grid, i)
    end
    sum(grid .> 1)
end

function part2()
    data = process_data()
    #= @timeit to "ext1" =# min1, max1 = extrema(x->getindex(x, 1), data)
    #= @timeit to "ext2" =# min2, max2 = extrema(x->getindex(x, 2), data)
    #= @timeit to "ext3" =# min3, max3 = extrema(x->getindex(x, 3), data)
    #= @timeit to "ext4" =# min4, max4 = extrema(x->getindex(x, 4), data)
    #= @timeit to "max_x" =# max_x = max(max1, max3)
    #= @timeit to "min_x" =# min_x = min(min1, min3)
    #= @timeit to "max_y" =# max_y = max(max2, max4)
    #= @timeit to "min_y" =# min_y = min(min2, min4)
    grid = OffsetArray(zeros(Int8, 1-min_x+max_x, 1-min_y+max_y), (min_x:max_x, min_y:max_y))
    for i in data
        assign2points_between!(grid, i)
    end
    sum(grid .> 1)
end


end # module

if false
# Day05.reset_timer!(Day05.to)
println(Day05.part1())
# show(Day05.to)
# @btime Day05.part1()
Day05.submit(Day05.part1(), Day05.cur_day, 1)
println(Day05.part2())
Day05.submit(Day05.part2(), Day05.cur_day, 2)
@btime Day05.part1()
@btime Day05.part2()
end
