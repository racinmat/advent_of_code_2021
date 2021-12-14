module Day14

using DrWatson
quickactivate(@__DIR__)
using StatsBase
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
# const raw_data = cur_day |> read_input
const raw_data = cur_day |> read_file("input_test.txt")
function read_pattern(row)
    k,v = split(row, " -> ")
    k => v
end
process_data() = raw_data |> x->split(x, "\n\n") .|> read_lines |> x->(x[1][1],Dict(read_pattern.(x[2])))

function iteration(data, patterns)
    new_data = data[1:1]
    i = 1
    for i in 1:length(data)-1
        if haskey(patterns, data[i:i+1])
            new_data *= patterns[data[i:i+1]] * data[i+1]
        # else
        #     new_data *= data[i:i+1]
        end
    end
    new_data
end

function part1()
    data, patterns = process_data()
    prev_len = 0
    a_len = length(data)
    a_hist = countmap(data)
    @info "len" a_len a_hist
    num_steps = 10
    for i in 1:num_steps
        prev_len = a_len
        prev_hist = a_hist
        data = iteration(data, patterns)
        a_len = length(data)
        a_hist = countmap(data)
        hist_diff = Dict(k => v-get(prev_hist,k,0) for (k,v) in a_hist)
        @info "len" a_len (a_len - prev_len) a_hist hist_diff
    end
    a, b = data |> countmap |> values |> extrema
    b - a
end

function part2()
    data, patterns = process_data()
    num_steps = 40
    for i in 1:num_steps
        data = iteration(data, patterns)
    end
    a, b = data |> countmap |> values |> extrema
    b - a
end


end # module

if false
println(Day14.part1())
Day14.submit(Day14.part1(), Day14.cur_day, 1)
println(Day14.part2())
Day14.submit(Day14.part2(), Day14.cur_day, 2)
end
