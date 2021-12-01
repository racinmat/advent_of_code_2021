module Day01

using DrWatson
quickactivate(@__DIR__)
using Pipe:@pipe
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_numbers

function part1()
    data = process_data()
    @pipe data |> diff |> mapreduce(>(0), +, _)
end

function part2()
    data = process_data()
    windows = [sum(data[i-2:i]) for i in 3:length(data)]
    @pipe windows |> diff |> mapreduce(>(0), +, _)
end


end # module

if false
println(Day01.part1())
Day01.submit(Day01.part1(), Day01.cur_day, 1)
println(Day01.part2())
Day01.submit(Day01.part2(), Day01.cur_day, 2)
end
