module Day06

using DrWatson
quickactivate(@__DIR__)
using Pipe:@pipe
using StatsBase
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = @pipe raw_data |> read_numbers(_, ",")

function new_state(data)
    new_data = copy(data)
    new_data[data .> 0] .-= 1
    new_data[data .== 0] .= 6
    [new_data; ones(Int, count(data .== 0)) .* 8]
end

transition_matrix = [
 #  8 7 6 5 4 3 2 1 0
    0 0 0 0 0 0 0 0 1 #8
    1 0 0 0 0 0 0 0 0 #7
    0 1 0 0 0 0 0 0 1 #6
    0 0 1 0 0 0 0 0 0 #5
    0 0 0 1 0 0 0 0 0 #4
    0 0 0 0 1 0 0 0 0 #3
    0 0 0 0 0 1 0 0 0 #2
    0 0 0 0 0 0 1 0 0 #1
    0 0 0 0 0 0 0 1 0 #0
]'

data2states(data) = reverse(counts(data, 0:8))'
function part1()
    data = process_data()
    states = data2states(data)
    num_days = 80
    # naive solution for part 1 and verification of the matrix approach
    # for i in 1:num_days
    #     data = new_state(data)
    # end
    transition_matrix_total = transition_matrix ^ num_days
    # length(data)
    sum(states * transition_matrix_total)
end

function part2()
    data = process_data()
    states = data2states(data)
    num_days = 256
    transition_matrix_total = transition_matrix ^ num_days
    sum(states * transition_matrix_total)
end


end # module

if false
println(Day06.part1())
Day06.submit(Day06.part1(), Day06.cur_day, 1)
println(Day06.part2())
Day06.submit(Day06.part2(), Day06.cur_day, 2)
end
