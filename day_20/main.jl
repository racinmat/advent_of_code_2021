module Day20

using DrWatson
quickactivate(@__DIR__)
using Base.Iterators
using Pipe:@pipe
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = @pipe(raw_data |> replace_chars("."=>"0", "#"=>"1") |> split(_, "\n\n")) .|> read_lines .|> x->collect.(x) .|> (x->parse.(Bool, x)) |> x->reduce(hcat, x)'

print_map(a_map) = print(join([join([i ? '#' : '.' for i in r]) for r in eachrow(a_map)], '\n') * "\n\n")

function perform_iteration(a_big_map, inner_range_x, inner_range_y, pattern, to1)
    if pattern[1] == 1 && to1
        a_big_map_new = trues(size(a_big_map))
    else
        a_big_map_new = falses(size(a_big_map))
    end
    incr = 1
    # incr = 3
    # incr = 4
    inner_range_x = (inner_range_x.start-incr):(inner_range_x.stop+incr)
    inner_range_y = (inner_range_y.start-incr):(inner_range_y.stop+incr)
    for i in CartesianIndices((inner_range_x, inner_range_y))
        # a_range_x = max(i.I[1]-1,1):min(i.I[1]+1, size(a_map,1))
        a_range_x = i.I[1]-1:i.I[1]+1
        # a_range_y = max(i.I[2]-1,1):min(i.I[2]+1, size(a_map,1))
        a_range_y = i.I[2]-1:i.I[2]+1
        
        a_idx = bits2num(a_big_map[a_range_x, a_range_y]' |> flatten)
        new_val = pattern[a_idx + 1]
        # @info "setting" i a_idx new_val
        a_big_map_new[i] = new_val
    end
    a_big_map_new, inner_range_x, inner_range_y, !to1
end

function part1()
    pattern, a_map = process_data()
    a_big_map = zeros(Bool, size(a_map).+6)
    # a_big_map = zeros(Bool, size(a_map).+10)
    # a_big_map = falses(size(a_map).+20)
    a_big_center_x, a_big_center_y = size(a_big_map) .÷ 2
    a_center_x, a_center_y = size(a_map) .÷ 2
    inner_range_x = a_big_center_x .+ ((1:size(a_map,1)) .- a_center_x)
    inner_range_y = a_big_center_y .+ ((1:size(a_map,2)) .- a_center_y)
    a_big_map[inner_range_x, inner_range_y] = a_map
    # print_map(a_big_map)
    length(inner_range_x)
    to1 = true
    for i in 1:2
        a_big_map, inner_range_x, inner_range_y, to1 = perform_iteration(a_big_map, inner_range_x, inner_range_y, pattern, to1)
        # print_map(a_big_map)
    end
    sum(a_big_map)
end

function part2()
    pattern, a_map = process_data()
    # a_big_map = zeros(Bool, size(a_map).+4)
    # a_big_map = zeros(Bool, size(a_map).+10)
    a_big_map = falses(size(a_map).+102)
    a_big_center_x, a_big_center_y = size(a_big_map) .÷ 2
    a_center_x, a_center_y = size(a_map) .÷ 2
    inner_range_x = a_big_center_x .+ ((1:size(a_map,1)) .- a_center_x)
    inner_range_y = a_big_center_y .+ ((1:size(a_map,2)) .- a_center_y)
    a_big_map[inner_range_x, inner_range_y] = a_map
    # print_map(a_big_map)
    length(inner_range_x)
    to1 = true
    for i in 1:50
        a_big_map, inner_range_x, inner_range_y, to1 = perform_iteration(a_big_map, inner_range_x, inner_range_y, pattern, to1)
        # print_map(a_big_map)
    end
    sum(a_big_map)
end


end # module

if false
println(Day20.part1())
Day20.submit(Day20.part1(), Day20.cur_day, 1)
println(Day20.part2())
Day20.submit(Day20.part2(), Day20.cur_day, 2)
end
# 5860 is too high