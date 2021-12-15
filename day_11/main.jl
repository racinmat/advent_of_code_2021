module Day11

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = (raw_data |> read_lines .|> x->split(x, "") .|> x->parse.(Int16, x)) |> x->reduce(hcat, x)'

function update_in_8neighborhood!(m, i, flashes)
    neighbors = CartesianIndex[]
    @inbounds i.I[1] > 1 && i.I[2] > 1 && push!(neighbors, CartesianIndex(-1, -1))
    @inbounds i.I[1] > 1 && push!(neighbors, CartesianIndex(-1, 0))
    @inbounds i.I[1] > 1 && i.I[2] < size(m)[2] && push!(neighbors, CartesianIndex(-1, 1))
    @inbounds i.I[2] > 1 && push!(neighbors, CartesianIndex(0, -1))
    @inbounds i.I[1] < size(m)[1] && i.I[2] > 1 && push!(neighbors, CartesianIndex(1, -1))
    @inbounds i.I[1] < size(m)[1] && push!(neighbors, CartesianIndex(1, 0))
    @inbounds i.I[2] < size(m)[2] && push!(neighbors, CartesianIndex(0, 1))
    @inbounds i.I[1] < size(m)[1] && i.I[2] < size(m)[2] && push!(neighbors, CartesianIndex(1, 1))
    num_flashes = 0
    for j in neighbors
        k = j+i
        if k ∉ flashes
            m[k] += 1
        end
        if m[k] > 9
            push!(flashes, k)
            num_flashes += 1
            m[k] = 0
        end
    end
    num_flashes
end

function iteration(data)
    new_data = data .+ 1
    flashes = findall(new_data .> 9)
    new_data[flashes] .= 0
    num_flashes = length(flashes)
    for f in flashes
        num_flashes += update_in_8neighborhood!(new_data, f, flashes)
    end
    new_data, num_flashes
end

function part1()
    data = process_data()
    sum_flashes = 0
    for i in 1:100
        data, new_flashes = iteration(data)
        sum_flashes += new_flashes
    end
    sum_flashes
end

function part2()
    data = process_data()
    length(data)
    for i in 1:10_000
        data, new_flashes = iteration(data)
        if new_flashes == length(data)
            return i
        end
    end
    return 0
end


end # module

if false
using BenchmarkTools
println(Day11.part1())
@btime Day11.part1()
Day11.submit(Day11.part1(), Day11.cur_day, 1)
println(Day11.part2())
@btime Day11.part2()
Day11.submit(Day11.part2(), Day11.cur_day, 2)
end
