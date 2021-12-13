module Day10

using DrWatson
quickactivate(@__DIR__)
using DataStructures, Statistics
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines

const closes = Dict(
    '>' => '<',
    ']' => '[',
    '}' => '{',
    ')' => '(',
)
const part1points = Dict(
    '>' => 25137,
    ']' => 57,
    '}' => 1197,
    ')' => 3,
)
const part2points = Dict(
    '<' => 4,
    '[' => 2,
    '{' => 3,
    '(' => 1,
)

function calc_row_part1(row)
    s = Stack{Char}()
    ch = row[5]
    ch = ')'
    for ch in row
        if ch ∈ "(<[{"
            push!(s, ch)
        else
            if first(s) == closes[ch]
                pop!(s)
            else
                return part1points[ch]
            end
        end
    end
    return 0
end

function calc_row_part2(row)
    total_score = 0
    s = Stack{Char}()
    ch = row[5]
    ch = ')'
    for ch in row
        if ch ∈ "(<[{"
            push!(s, ch)
        else
            if first(s) == closes[ch]
                pop!(s)
            else
                return part1points[ch]
            end
        end
    end
    while !isempty(s)
        ch = pop!(s)
        total_score *= 5
        total_score += part2points[ch]
    end
    return total_score
end

function part1()
    data = process_data()
    mapreduce(calc_row_part1, +, data)
end

function part2()
    data = process_data()
    incomplete_rows = filter(x -> calc_row_part1(x) == 0, data)
    Int(median(calc_row_part2.(incomplete_rows)))
end


end # module

if false
println(Day10.part1())
Day10.submit(Day10.part1(), Day10.cur_day, 1)
println(Day10.part2())
Day10.submit(Day10.part2(), Day10.cur_day, 2)
end
