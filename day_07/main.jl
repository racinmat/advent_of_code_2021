module Day07

using DrWatson
quickactivate(@__DIR__)
using Pipe, Statistics
using TimerOutputs, BenchmarkTools
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = @pipe raw_data |> read_numbers(_, ",", Int32)

const to = TimerOutput()
reset_timer!(to)

function part1()
    data = process_data()
    res_position = Int(median(data))
    sum(abs.(data .- res_position))
end

# cumsum(0:x) is simply adding consecutive numbers which we can describe analytically
dist_part2(x) = x*(x+1)÷2

function part2()
    @timeit to "process_data" data = process_data()
    @timeit to "extrema" d_min, d_max = extrema(data)
    @timeit to "metric" minimum(i -> sum(dist_part2(abs(x - i)) for x in data), d_min:d_max)
end


end # module

if false
using BenchmarkTools
Day07.reset_timer!(Day07.to)
println(Day07.part1())
show(Day07.to)
@btime Day07.part1()

@btime Day07.part1()
Day07.submit(Day07.part1(), Day07.cur_day, 1)
Day07.reset_timer!(Day07.to)
println(Day07.part2())
show(Day07.to)
@btime Day07.part2()
Day07.submit(Day07.part2(), Day07.cur_day, 2)
end
