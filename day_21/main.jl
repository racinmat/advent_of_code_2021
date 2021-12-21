module Day21

using DrWatson
quickactivate(@__DIR__)
using Base.Iterators, StatsBase
include(projectdir("misc.jl"))

function parse_row(row)
    m = match(r"Player (\d+) starting position: (\d+)", row)
    parse(Int16, m[1]) => parse(Int16, m[2])
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = raw_data |> read_lines .|> parse_row |> Dict

incr_pos_mod(a, b, base=10) = (a + b - 1) % base + 1

function part1()
    positions = process_data()
    scores = Dict(k=>0 for k in keys(positions))
    dice = 1:100
    player1 = true
    # i = partition(cycle(dice), 3) |> first
    num_rolls = 0
    for i in partition(cycle(dice), 3)
        num_rolls += 3
        p_idx = player1 ? 1 : 2
        positions[p_idx] = incr_pos_mod(positions[p_idx], sum(i))
        scores[p_idx] += positions[p_idx]
        player1 = !player1
        if scores |> values |> maximum >= 1000
            # @info "break" i
            break
        end
    end
    # positions
    # scores
    minimum(values(scores)) * num_rolls
end

# const all_die_options = reshape(product(1:3, 1:3, 1:3) |> collect, :)
const all_die_options = reshape(product(1:3, 1:3, 1:3) |> collect, :) .|> sum |> countmap

function play_game(positions, scores, player1)
    max_score = 21
    # max_score = 10
    # i = all_die_options |> first
    wins1, wins2 = 0, 0
    # if same sum has occured more times, I can count it once and multiply win nums
    for (i_sum, num_occurs) in all_die_options
        positions2 = copy(positions)
        scores2 = copy(scores)
        p_idx = player1 ? 1 : 2
        positions2[p_idx] = incr_pos_mod(positions2[p_idx], i_sum)
        scores2[p_idx] += positions2[p_idx]
        if scores2 |> values |> maximum >= max_score
            if scores2[1] >= max_score
                wins1 += num_occurs
            else
                wins2 += num_occurs
            end
        else
            wins1_i, wins2_i = play_game(positions2, scores2, !player1)
            wins1 += wins1_i * num_occurs
            wins2 += wins2_i * num_occurs
        end
    end
    wins1, wins2
end

function part2()
    # instead of the naive iteration, I can use histogram
    positions = process_data()
    # this takes too long, does not work
    scores = Dict(k=>0 for k in keys(positions))
    wins1, wins2 = 0, 0
    player1 = true
    wins1, wins2 = play_game(positions, scores, player1)
    max(wins1, wins2)
end
# for original implementation and max_score 6
# (30498, 7203)

end # module

if false
using BenchmarkTools
println(Day21.part1())
@btime Day21.part1()
Day21.submit(Day21.part1(), Day21.cur_day, 1)
println(Day21.part2())
@btime Day21.part2()
Day21.submit(Day21.part2(), Day21.cur_day, 2)
end
