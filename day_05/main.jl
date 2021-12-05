module Day05

using DrWatson
quickactivate(@__DIR__)
using LazySets, Combinatorics, OffsetArrays
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")

# parse_row(x) = (split(x, " -> ") .|> (x->split(x, ",") .|> x->parse(Float32, x))) |> x->LineSegment(x...)
parse_row(x) = split(x, " -> ") .|> (x->split(x, ",") .|> x->parse(Int, x)) |> x->reduce(hcat, x)
is_axis_aligned(x::LineSegment) = x.p[1] == x.q[1] || x.p[2] == x.q[2]
is_axis_aligned(x::Matrix) = x[1,1] == x[1,2] || x[2,1] == x[2,2]
process_data() = raw_data |> read_lines .|> parse_row
num_intersection_points(x::Vector{<:LineSegment}) = intersection(x[1], x[2]) |> num_intersection_points
num_intersection_points(::EmptySet) = 0
num_intersection_points(::Singleton) = 1
num_intersection_points(x::LineSegment) = Int(max(abs(x.p[1] - x.q[1]), abs(x.p[2] - x.q[2]))) + 1

function get_points_between(i)
    dif = i[:,2] - i[:,1]
    max_dif = maximum(abs.(dif))
    (i[:,1]+Int.(dif/max_dif)*j for j in 0:max_dif)
    # [i[:,1]+Int.(dif/max_dif)*j for j in 0:max_dif]
end

function part1()
    data = process_data()
    max_x = max(maximum(getindex.(data, 1)), maximum(getindex.(data, 3)))
    min_x = min(minimum(getindex.(data, 1)), minimum(getindex.(data, 3)))
    max_y = max(maximum(getindex.(data, 2)), maximum(getindex.(data, 4)))
    min_y = min(minimum(getindex.(data, 2)), minimum(getindex.(data, 4)))
    grid = OffsetArray(zeros(Int, 1-min_x+max_x, 1-min_y+max_y), (min_x:max_x, min_y:max_y))
    axis_aligned = filter(is_axis_aligned, data)
    for i in axis_aligned
        for j in get_points_between(i)
            grid[j...] += 1
        end
    end
    sum(grid .> 1)
end

function part2()
    data = process_data()
    max_x = max(maximum(getindex.(data, 1)), maximum(getindex.(data, 3)))
    min_x = min(minimum(getindex.(data, 1)), minimum(getindex.(data, 3)))
    max_y = max(maximum(getindex.(data, 2)), maximum(getindex.(data, 4)))
    min_y = min(minimum(getindex.(data, 2)), minimum(getindex.(data, 4)))
    grid = OffsetArray(zeros(Int, 1-min_x+max_x, 1-min_y+max_y), (min_x:max_x, min_y:max_y))
    for i in data
        for j in get_points_between(i)
            grid[j...] += 1
        end
    end
    sum(grid .> 1)
end


end # module

if false
println(Day05.part1())
Day05.submit(Day05.part1(), Day05.cur_day, 1)
println(Day05.part2())
Day05.submit(Day05.part2(), Day05.cur_day, 2)
end
