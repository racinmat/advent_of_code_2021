module Day09

using DrWatson
quickactivate(@__DIR__)
using ImageFiltering, OffsetArrays, StatsBase
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = (raw_data |> read_lines .|> x->split(x, "") .|> x->parse.(Int16, x)) |> x->reduce(hcat, x)'

function find_lowpoints(data)
    k1 = OffsetArray([
        -1 1
    ], 0:0, 0:1)
    k2 = OffsetArray([
        1 -1
    ], 0:0, -1:0)
    k3 = OffsetArray([
        -1 1
    ]', 0:1, 0:0)
    k4 = OffsetArray([
        1 -1
    ]', -1:0, -0:0)
    lowpoints = 
        (imfilter(data, k4, "reflect") .> 0) .+ 
        (imfilter(data, k3, "reflect") .> 0) .+ 
        (imfilter(data, k2, "reflect") .> 0) .+ 
        (imfilter(data, k1, "reflect") .> 0) .== 4
    lowpoints
end

function get_in_4neighborhood(m, i, cond)
    neighbors = CartesianIndex[]
    @inbounds i.I[1] > 1 && push!(neighbors, CartesianIndex(-1, 0))
    @inbounds i.I[2] > 1 && push!(neighbors, CartesianIndex(0, -1))
    @inbounds i.I[1] < size(m)[1] && push!(neighbors, CartesianIndex(1, 0))
    @inbounds i.I[2] < size(m)[2] && push!(neighbors, CartesianIndex(0, 1))
    @inbounds [j for j in neighbors if cond(i+j)]
end

function part1()
    data = process_data()
    lowpoints = find_lowpoints(data)
    sum(data[lowpoints]) + sum(lowpoints)
end

function part2()
    data = process_data()
    lowpoints = find_lowpoints(data)
    basins = zeros(UInt8, size(data))
    basins[lowpoints] = 1:sum(lowpoints)
    points2visit = findall(>(0), lowpoints)
    while !isempty(points2visit)
        # p = points2visit[1]
        points2visit_next = []
        for p in points2visit
            for q in get_in_4neighborhood(basins, p, x->basins[x] == 0 && data[x] != 9)
                r = q+p
                basins[r] = basins[p]
                push!(points2visit_next, r)
            end
        end
        points2visit = points2visit_next
    end
    prod(partialsort(counts(basins)[2:end], 1:3, rev=true))
end


end # module

if false
println(Day09.part1())
Day09.submit(Day09.part1(), Day09.cur_day, 1)
println(Day09.part2())
Day09.submit(Day09.part2(), Day09.cur_day, 2)
end
