module Day21

using DrWatson
quickactivate(@__DIR__)
using Base.Iterators, StatsBase
# using BenchmarkTools
include(projectdir("misc.jl"))

function parse_row(row)
    m = match(r"Player (\d+) starting position: (\d+)", row)
    parse(Int16, m[1]) => parse(Int16, m[2])
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = raw_data |> read_lines .|> parse_row |> Dict |> x->(UInt8(x[1]), UInt8(x[2]))

incr_pos_mod(a, b, base=10) = (a + b - 1) % base + 1
incr_pos_mod(a::T, b::T, base=10) where T = (a + b - one(T)) % T(base) + one(T)

function part1()
    pos1, pos2 = process_data()
    score1, score2 = zero(UInt8), zero(UInt8)
    dice = 1:100
    player1 = true
    # i = partition(cycle(dice), 3) |> first
    num_rolls = 0
    for i in partition(cycle(dice), 3)
        num_rolls += 3
        if player1
            pos1 = incr_pos_mod(pos1, sum(i))
            score1 += pos1
        else
            pos2 = incr_pos_mod(pos2, sum(i))
            score2 += pos2
        end
        player1 = !player1
        if max(score1, score2) >= 1000
            # @info "break" i
            break
        end
    end
    # positions
    # scores
    min(score1, score2) * num_rolls
end

# const all_die_options = reshape(product(1:3, 1:3, 1:3) |> collect, :)
const all_die_options = reshape(product(1:3, 1:3, 1:3) |> collect, :) .|> sum |> countmap |> x->Dict(UInt8(k)=>v for (k,v) in x)

function play_game(pos1, pos2, score1, score2, player1)
    max_score = UInt8(21)
    # max_score = UInt8(10)
    wins1, wins2 = 0, 0
    # i = all_die_options |> first
    # if same sum has occured more times, I can count it once and multiply win nums
    # i_sum, num_occurs = all_die_options |> first
    for (i_sum, num_occurs) in all_die_options
        pos1i, pos2i = pos1, pos2
        score1i, score2i = score1, score2
        if player1
            pos1i = incr_pos_mod(pos1i, i_sum)
            score1i += pos1i
        else
            pos2i = incr_pos_mod(pos2i, i_sum)
            score2i += pos2i
        end
        if max(score1i, score2i) >= max_score
            if score1i >= max_score
                wins1 += num_occurs
            else
                wins2 += num_occurs
            end
        else
            wins1_i, wins2_i = play_game(pos1i, pos2i, score1i, score2i, !player1)
            wins1 += wins1_i * num_occurs
            wins2 += wins2_i * num_occurs
        end
    end
    wins1, wins2
end

function part2()
    # instead of the naive iteration, I can use histogram
    pos1, pos2 = process_data()
    # this takes too long, does not work
    # scores = Dict(k=>0 for k in keys(positions))
    score1, score2 = zero(UInt8), zero(UInt8)
    player1 = true
    
    wins1, wins2 = play_game(pos1, pos2, score1, score2, player1)
    max(wins1, wins2)
end
# for original implementation and max_score 10
# (18973591, 12657100)

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
