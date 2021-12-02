module Day02

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

function parse_row(str)
    vals = split(str)
    vals[1], parse(Int, vals[2])
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines .|> parse_row

function process_row_part1((depth, forward), (direction, value))
    if direction == "forward"
        depth, forward + value
    elseif direction == "up"
        depth - value, forward
    elseif direction == "down"
        depth + value, forward
    end
end

function process_row_part2((depth, forward), (direction, value, aim))
    if direction == "forward"
        depth, forward + value, aim
    elseif direction == "up"
        depth, forward, aim - value
    elseif direction == "down"
        depth, forward, aim + value
    end
end

function part1()
    data = process_data()
    coords = reduce(process_row, data, init=(0, 0))
    reduce(*, coords)
end

function part2()
    data = process_data()
    coords = reduce(process_row, data, init=(0, 0, 0))
    reduce(*, coords)
end


end # module

if false
println(Day02.part1())
Day02.submit(Day02.part1(), Day02.cur_day, 1)
println(Day02.part2())
Day02.submit(Day02.part2(), Day02.cur_day, 2)
end
