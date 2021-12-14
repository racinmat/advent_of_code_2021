module Day14

using DrWatson
quickactivate(@__DIR__)
using StatsBase, DataStructures
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
function read_pattern(row)
    k,v = split(row, " -> ")
    k => v
end
process_data() = raw_data |> x->split(x, "\n\n") .|> read_lines |> x->(x[1][1],Dict(read_pattern.(x[2])))

function iteration(data::AbstractString, patterns)
    new_data = data[1:1]
    i = 1
    for i in 1:length(data)-1
        if haskey(patterns, data[i:i+1])
            new_data *= patterns[data[i:i+1]] * data[i+1]
        end
    end
    new_data
end

function iteration(data::AbstractDict, patterns)
    new_data = copy(data)
    for (k,v) in data
        if haskey(patterns, k)
            new_data[k[1]*patterns[k]] += v
            new_data[patterns[k]*k[2]] += v
            new_data[k] -= v
        end
    end
    new_data
end

function part1()
    data, patterns = process_data()
    data_h = DefaultDict(0, countmap(data[i:i+1] for i in 1:length(data)-1))
    num_steps = 10
    for i in 1:num_steps
        data_h = iteration(data_h, patterns)
    end
    new_d = DefaultDict(0)
    for (k,v) in data_h
        new_d[k[1]] += v
    end
    new_d[data[end]] += 1
    a, b = new_d |> values |> extrema
    b - a
end

function part2()
    data, patterns = process_data()
    data_h = DefaultDict(0, countmap(data[i:i+1] for i in 1:length(data)-1))
    num_steps = 40
    for i in 1:num_steps
        data_h = iteration(data_h, patterns)
    end
    new_d = DefaultDict(0)
    for (k,v) in data_h
        new_d[k[1]] += v
    end
    new_d[data[end]] += 1
    a, b = new_d |> values |> extrema
    b - a
end


end # module

if false
println(Day14.part1())
Day14.submit(Day14.part1(), Day14.cur_day, 1)
println(Day14.part2())
Day14.submit(Day14.part2(), Day14.cur_day, 2)
end
