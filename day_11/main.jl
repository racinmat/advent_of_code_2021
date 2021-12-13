module Day11

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = (raw_data |> read_lines .|> x->split(x, "") .|> x->parse.(Int16, x)) |> x->reduce(hcat, x)'

function get_in_8neighborhood(m, i, cond)
    neighbors = CartesianIndex[]
    @inbounds i.I[1] > 1 && i.I[2] > 1 && push!(neighbors, CartesianIndex(-1, -1))
    @inbounds i.I[1] > 1 && push!(neighbors, CartesianIndex(-1, 0))
    @inbounds i.I[1] > 1 && i.I[2] < size(m)[2] && push!(neighbors, CartesianIndex(-1, 1))
    @inbounds i.I[2] > 1 && push!(neighbors, CartesianIndex(0, -1))
    @inbounds i.I[1] < size(m)[1] && i.I[2] > 1 && push!(neighbors, CartesianIndex(1, -1))
    @inbounds i.I[1] < size(m)[1] && push!(neighbors, CartesianIndex(1, 0))
    @inbounds i.I[2] < size(m)[2] && push!(neighbors, CartesianIndex(0, 1))
    @inbounds i.I[1] < size(m)[1] && i.I[2] < size(m)[2] && push!(neighbors, CartesianIndex(1, 1))
    @inbounds [j for j in neighbors if cond(i+j)]
end

function iteration(data)
    new_data = data .+ 1
    flashes = findall(new_data .> 9)
    new_data[flashes] .= 0
    num_flashes = length(flashes)
    for f in flashes
        for j in get_in_8neighborhood(new_data, f, (i)->true)
            k = j+f
            if k ∉ flashes
                new_data[k] += 1
            end
            if new_data[k] > 9
                push!(flashes, k)
                num_flashes += 1
                new_data[k] = 0
            end
        end
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
println(Day11.part1())
Day11.submit(Day11.part1(), Day11.cur_day, 1)
println(Day11.part2())
Day11.submit(Day11.part2(), Day11.cur_day, 2)
end
