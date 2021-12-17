module Day17

using DrWatson
quickactivate(@__DIR__)
using Base.Iterators
# using TimerOutputs, BenchmarkTools
include(projectdir("misc.jl"))

# const to = TimerOutput()
# reset_timer!(to)

function parse_row(str)
    m = match(r"target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)", str)
    x1, x2, y1, y2 = parse.(Int32, m.captures)
    return (x1,x2), (y1, y2)
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = raw_data |> parse_row

# I can't use the Int16, because some (although non-valid solutions) go beyong int16 typemax and after that I see they miss the rectangle

# I don't need the initial velocity, so I can mutate it
function will_any_hit!(init_vel, x_range, y_range)
    #= @timeit to "typemin" =# max_y = typemin(Int32)
    #= @timeit to "copy_init_vel" =# cur_vel = init_vel
    #= @timeit to "cur_pos" =# cur_pos = Int32[0, 0]
    #= @timeit to "do_steps" =# @inbounds while #= @timeit to "eval_in_range" =# cur_pos[1] < x_range[2] && cur_pos[2] > y_range[1]
        #= @timeit to "+=cur_vel" =# cur_pos .+= cur_vel
        #= @timeit to "max(max_y, cur_pos[2])" =# max_y = max(max_y, cur_pos[2])
        #= @timeit to "-=sign(cur_vel[1])" =# cur_vel[1] -= sign(cur_vel[1])
        #= @timeit to "-=1" =# cur_vel[2] -= 1
        #= @timeit to "eval_in_range" =# x_range[1] <= cur_pos[1] <= x_range[2] && y_range[1] <= cur_pos[2] <= y_range[2] && return true, max_y
    end
    return false, max_y
end

function part1()
    x_range, y_range = process_data()
    total_max_y = typemin(Int32)
    for (i, j) in product(0:Int32(x_range[2]), 0:Int32(1000))
        #= @timeit to "init_vel" =# init_vel = [i,j]
        #= @timeit to "will_any_hit!" =# will_hit, max_y = will_any_hit!(init_vel, x_range, y_range)
        if will_hit
            total_max_y = max(total_max_y, max_y)
        end
    end
    return total_max_y
end

function part2()
    x_range, y_range = process_data()
    num_valid_solutions = Int32(0)
    for (i, j) in product(0:Int32(x_range[2]), Int32(-1000):Int32(1000))
        init_vel = [i,j]
        num_valid_solutions += will_any_hit!(init_vel, x_range, y_range)[1]
    end
    return num_valid_solutions
end

end # module

if false
using BenchmarkTools
Day17.reset_timer!(Day17.to)
println(Day17.part1())
show(Day17.to)
@btime Day17.part1()
Day17.submit(Day17.part1(), Day17.cur_day, 1)
println(Day17.part2())
@btime Day17.part2()
Day17.submit(Day17.part2(), Day17.cur_day, 2)
end
