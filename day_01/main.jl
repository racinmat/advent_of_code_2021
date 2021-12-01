module Day01

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines .|> x -> parse(Int, x)

function part1()
    data = process_data()
    prev_i = data[1]
    c = 0
    for i in data[2:end]
        c += i > prev_i
        prev_i = i
    end
    c
end

function part2()
    data = process_data()
    prev_sum = sum(data[1:3])
    c = 0
    for i in 4:length(data)
        win_sum = sum(data[i-2:i])
        c += win_sum > prev_sum
        prev_sum = win_sum
    end
    c
end


end # module

if false
println(Day01.part1())
Day01.submit(Day01.part1(), Day01.cur_day, 1)
println(Day01.part2())
Day01.submit(Day01.part2(), Day01.cur_day, 2)
end
