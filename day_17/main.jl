module Day17

using DrWatson
quickactivate(@__DIR__)
using Base.Iterators
using TimerOutputs, BenchmarkTools
include(projectdir("misc.jl"))

const to = TimerOutput()
reset_timer!(to)

function parse_row(str)
    m = match(r"target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)", str)
    x1, x2, y1, y2 = parse.(Int32, m.captures)
    return (x1,x2), (y1, y2)
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = raw_data |> parse_row

# I don't need the initial velocity, so I can mutate it
function will_any_hit!(init_vel, x_range, y_range)
    @timeit to "typemin" max_y = typemin(Int32)
    @timeit to "copy_init_vel" cur_vel = init_vel
    @timeit to "cur_pos" cur_pos = Int32[0, 0]
    @timeit to "do_steps" @inbounds while cur_pos[1] < x_range[2] && cur_pos[2] > y_range[1]
        @timeit to "+=cur_vel" cur_pos .+= cur_vel
        @timeit to "max(max_y, cur_pos[2])" max_y = max(max_y, cur_pos[2])
        @timeit to "-=sign(cur_vel[1])" cur_vel[1] -= sign(cur_vel[1])
        @timeit to "-=1" cur_vel[2] -= 1
        @timeit to "eval_in_range" x_range[1] <= cur_pos[1] <= x_range[2] && y_range[1] <= cur_pos[2] <= y_range[2] && return true, max_y
    end
    return false, max_y
end

function part1()
    x_range, y_range = process_data()
    total_max_y = typemin(Int32)
    product(0:1000, 0:1000) |> first
    for (i, j) in product(0:Int32(1000), 0:Int32(1000))
        @timeit to "init_vel" init_vel = [i,j]
        @timeit to "will_any_hit!" will_hit, max_y = will_any_hit!(init_vel, x_range, y_range)
        if will_hit
            total_max_y = max(total_max_y, max_y)
        end
    end
    return total_max_y
end

function part2()
    x_range, y_range = process_data()
    i=Int32(9)
    j=Int32(0)
    num_valid_solutions = 0
    for i in 0:Int32(1000)
        for j in Int32(-1000):Int32(1000)
            init_vel = [i,j]
            will_hit, max_y = will_any_hit!(init_vel, x_range, y_range)
            if will_hit
                num_valid_solutions += 1
            end
        end
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
Day17.submit(Day17.part2(), Day17.cur_day, 2)
end

#  ───────────────────────────────────────────────────────────────────────────────────
#                                             Time                   Allocations      
#                                     ──────────────────────   ───────────────────────
#           Tot / % measured:              29.9s / 94.6%           1.75GiB / 91.1%

#  Section                    ncalls     time   %tot     avg     alloc   %tot      avg
#  ───────────────────────────────────────────────────────────────────────────────────
#  do_steps                    1.00M    27.9s  98.8%  27.9μs   1.44GiB  90.6%  1.51KiB
#    +=cur_vel                 19.4M    3.04s  10.7%   157ns   1.44GiB  90.6%    80.0B
#    max(max_y, cur_pos[2])    19.4M    1.81s  6.41%  93.6ns     0.00B  0.00%    0.00B
#    -=sign(cur_vel[1])        19.4M    1.70s  6.01%  87.8ns     0.00B  0.00%    0.00B
#    -=1                       19.4M    1.67s  5.91%  86.3ns     0.00B  0.00%    0.00B
#    eval_in_range             19.4M    1.63s  5.77%  84.3ns   16.8KiB  0.00%    0.00B
#  cur_pos                     1.00M    132ms  0.47%   131ns   76.4MiB  4.69%    80.0B
#  copy_init_vel               1.00M    127ms  0.45%   126ns   76.4MiB  4.69%    80.0B
#  typemin                     1.00M   88.1ms  0.31%  87.9ns     0.00B  0.00%    0.00B
#  ───────────────────────────────────────────────────────────────────────────────────

#  ───────────────────────────────────────────────────────────────────────────────────
#                                             Time                   Allocations
#                                     ──────────────────────   ───────────────────────
#           Tot / % measured:              28.4s / 96.8%           1.71GiB / 92.9%

#  Section                    ncalls     time   %tot     avg     alloc   %tot      avg
#  ───────────────────────────────────────────────────────────────────────────────────
#  do_steps                    1.00M    27.2s  98.9%  27.1μs   1.44GiB  90.6%  1.51KiB
#    +=cur_vel                 19.4M    2.81s  10.2%   145ns   1.44GiB  90.6%    80.0B
#    max(max_y, cur_pos[2])    19.4M    1.69s  6.15%  87.2ns     0.00B  0.00%    0.00B
#    -=sign(cur_vel[1])        19.4M    1.67s  6.08%  86.3ns     0.00B  0.00%    0.00B
#    -=1                       19.4M    1.58s  5.74%  81.4ns     0.00B  0.00%    0.00B
#    eval_in_range             19.4M    1.53s  5.59%  79.2ns   16.8KiB  0.00%    0.00B
#  cur_pos                     1.00M    123ms  0.45%   122ns   76.4MiB  4.69%    80.0B
#  copy_init_vel               1.00M    107ms  0.39%   107ns   76.4MiB  4.69%    80.0B
#  typemin                     1.00M   76.6ms  0.28%  76.5ns     0.00B  0.00%    0.00B
#  ───────────────────────────────────────────────────────────────────────────────────

#  ───────────────────────────────────────────────────────────────────────────────────
#                                             Time                   Allocations
#                                     ──────────────────────   ───────────────────────
#           Tot / % measured:              30.3s / 96.5%           1.64GiB / 92.6%

#  Section                    ncalls     time   %tot     avg     alloc   %tot      avg
#  ───────────────────────────────────────────────────────────────────────────────────
#  do_steps                    1.00M    28.9s  98.9%  28.9μs   1.44GiB  95.1%  1.51KiB
#    +=cur_vel                 19.4M    3.10s  10.6%   160ns   1.44GiB  95.1%    80.0B
#    max(max_y, cur_pos[2])    19.4M    1.87s  6.40%  96.6ns     0.00B  0.00%    0.00B
#    -=sign(cur_vel[1])        19.4M    1.76s  6.04%  91.1ns     0.00B  0.00%    0.00B
#    -=1                       19.4M    1.75s  5.97%  90.1ns     0.00B  0.00%    0.00B
#    eval_in_range             19.4M    1.68s  5.75%  86.8ns   16.8KiB  0.00%    0.00B
#  cur_pos                     1.00M    138ms  0.47%   138ns   76.4MiB  4.92%    80.0B
#  typemin                     1.00M   90.5ms  0.31%  90.3ns     0.00B  0.00%    0.00B
#  copy_init_vel               1.00M   84.6ms  0.29%  84.4ns     0.00B  0.00%    0.00B
#  ───────────────────────────────────────────────────────────────────────────────────

#  ───────────────────────────────────────────────────────────────────────────────────
#                                             Time                   Allocations
#                                     ──────────────────────   ───────────────────────
#           Tot / % measured:              31.7s / 96.8%           1.62GiB / 92.6%

#  Section                    ncalls     time   %tot     avg     alloc   %tot      avg
#  ───────────────────────────────────────────────────────────────────────────────────
#  do_steps                    1.00M    30.4s  99.0%  30.3μs   1.44GiB  96.0%  1.51KiB
#    +=cur_vel                 19.4M    3.19s  10.4%   165ns   1.44GiB  96.0%    80.0B
#    max(max_y, cur_pos[2])    19.4M    1.93s  6.29%   100ns     0.00B  0.00%    0.00B
#    -=sign(cur_vel[1])        19.4M    1.85s  6.02%  95.4ns     0.00B  0.00%    0.00B
#    eval_in_range             19.4M    1.83s  5.97%  94.6ns   16.8KiB  0.00%    0.00B
#    -=1                       19.4M    1.81s  5.90%  93.5ns     0.00B  0.00%    0.00B
#  cur_pos                     1.00M    135ms  0.44%   135ns   61.2MiB  3.97%    64.0B
#  typemin                     1.00M   87.0ms  0.28%  86.9ns     0.00B  0.00%    0.00B
#  copy_init_vel               1.00M   83.5ms  0.27%  83.4ns     0.00B  0.00%    0.00B
#  ───────────────────────────────────────────────────────────────────────────────────

#  ───────────────────────────────────────────────────────────────────────────────────
#                                             Time                   Allocations
#                                     ──────────────────────   ───────────────────────
#           Tot / % measured:              27.7s / 97.0%            138MiB / 44.4%

#  Section                    ncalls     time   %tot     avg     alloc   %tot      avg
#  ───────────────────────────────────────────────────────────────────────────────────
#  do_steps                    1.00M    26.6s  98.9%  26.5μs   3.67KiB  0.01%    0.00B
#    +=cur_vel                 19.4M    1.88s  7.02%  97.3ns     0.00B  0.00%    0.00B
#    max(max_y, cur_pos[2])    19.4M    1.77s  6.60%  91.5ns     0.00B  0.00%    0.00B
#    -=sign(cur_vel[1])        19.4M    1.70s  6.32%  87.6ns     0.00B  0.00%    0.00B
#    eval_in_range             19.4M    1.64s  6.13%  84.9ns     0.00B  0.00%    0.00B
#    -=1                       19.4M    1.64s  6.11%  84.7ns     0.00B  0.00%    0.00B
#  cur_pos                     1.00M    132ms  0.49%   132ns   61.2MiB  100%     64.0B
#  typemin                     1.00M   79.5ms  0.30%  79.4ns     0.00B  0.00%    0.00B
#  copy_init_vel               1.00M   76.7ms  0.29%  76.5ns     0.00B  0.00%    0.00B
#  ───────────────────────────────────────────────────────────────────────────────────

#  ───────────────────────────────────────────────────────────────────────────────────
#                                             Time                   Allocations
#                                     ──────────────────────   ───────────────────────
#           Tot / % measured:              28.0s / 95.5%            154MiB / 89.6%

#  Section                    ncalls     time   %tot     avg     alloc   %tot      avg
#  ───────────────────────────────────────────────────────────────────────────────────
#  do_steps                    1.00M    26.3s  98.4%  26.2μs   3.67KiB  0.00%    0.00B
#    +=cur_vel                 19.4M    1.82s  6.81%  93.9ns     0.00B  0.00%    0.00B
#    max(max_y, cur_pos[2])    19.4M    1.77s  6.63%  91.4ns     0.00B  0.00%    0.00B
#    -=sign(cur_vel[1])        19.4M    1.68s  6.29%  86.8ns     0.00B  0.00%    0.00B
#    -=1                       19.4M    1.62s  6.05%  83.4ns     0.00B  0.00%    0.00B
#    eval_in_range             19.4M    1.61s  6.03%  83.2ns     0.00B  0.00%    0.00B
#  init_vel                    1.00M    134ms  0.50%   134ns   76.4MiB  55.6%    80.0B
#  cur_pos                     1.00M    117ms  0.44%   117ns   61.2MiB  44.4%    64.0B
#  typemin                     1.00M   83.7ms  0.31%  83.5ns     0.00B  0.00%    0.00B
#  copy_init_vel               1.00M   79.5ms  0.30%  79.4ns     0.00B  0.00%    0.00B
#  ───────────────────────────────────────────────────────────────────────────────────