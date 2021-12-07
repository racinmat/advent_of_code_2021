module Day07

using DrWatson
quickactivate(@__DIR__)
using Pipe, Statistics, OffsetArrays
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = @pipe raw_data |> read_numbers(_, ",")

function part1()
    data = process_data()
    res_position = Int(median(data))
    sum(abs.(data .- res_position))
end

function part2()
    data = Int32.(process_data())
    d_min, d_max = extrema(data)
    dist_prices = OffsetArray(Int32.(cumsum(0:d_max)),0:d_max)
    minimum(i -> sum(dist_prices[abs.(data .- i)]), d_min:d_max)
end


end # module

if false
println(Day07.part1())
Day07.submit(Day07.part1(), Day07.cur_day, 1)
println(Day07.part2())
Day07.submit(Day07.part2(), Day07.cur_day, 2)
end
