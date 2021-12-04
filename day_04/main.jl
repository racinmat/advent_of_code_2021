module Day04

using DrWatson
quickactivate(@__DIR__)
using Pipe:@pipe
using Base.Iterators
# using TimerOutputs
# using BenchmarkTools
include(projectdir("misc.jl"))

# const to = TimerOutput()
# reset_timer!(to)

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")

parse_grid(x) = @pipe x .|> split .|> parse.(Int, _) |> _[2:end] |> reduce(hcat, _)
load_grids(x) = @pipe x |> (partition(_, 6) .|> parse_grid) |> reshape(reduce(hcat, _), (5, 5, :))
process_data() = @pipe raw_data |> read_lines |> (parse.(Int, split(_[1], ",")), load_grids(_[2:end]))

const checked_const = -1
match_all_cols(y, val=checked_const) = match_all_dim(y, val, eachcol)
match_all_rows(y, val=checked_const) = match_all_dim(y, val, eachrow)
match_all_dim(y, val, eachf) = (any(row -> all(==(val), row), eachf(mat)) for mat in eachslice(y, dims=3))
sum_unchecked(grids, win_board) = sum(grids[grids[:, :, win_board] .!= checked_const, win_board])

function part1()
    numbers, grids = process_data()
    win_board = nothing
    last_num = nothing
    for i in numbers
        grids[grids .== i] .= checked_const
        match_cols = match_all_cols(grids)
        if any(match_cols)
            win_board = argmax(match_cols)
            last_num = i
            break
        end
        match_rows = match_all_rows(grids)
        if any(match_rows)
            win_board = argmax(match_rows)
            last_num = i
            break
        end
    end
    sum_unchecked(grids, win_board) * last_num
end

function part2()
    numbers, grids = process_data()
    win_board = nothing
    last_num = nothing
    for i in numbers
        win_board = argmin(match_all_cols(grids) .+ match_all_rows(grids))
        grids[grids .== i] .= checked_const
        if minimum(match_all_cols(grids) .+ match_all_rows(grids)) == 1
            last_num = i
            break
        end
    end

    sum_unchecked(grids, win_board) * last_num
end

end # module

if false
# Day04.reset_timer!(Day04.to)
println(Day04.part1())
# show(Day04.to)

Day04.submit(Day04.part1(), Day04.cur_day, 1)
println(Day04.part2())
Day04.submit(Day04.part2(), Day04.cur_day, 2)
end
