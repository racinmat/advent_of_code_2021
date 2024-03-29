module Day18

using DrWatson
quickactivate(@__DIR__)
using Combinatorics
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
# const raw_data = cur_day |> read_file("input_test2.txt")
# const raw_data = cur_day |> read_file("input_test3.txt")
# const raw_data = cur_day |> read_file("input_test4.txt")
# const raw_data = cur_day |> read_file("input_test5.txt")
# const raw_data = cur_day |> read_file("input_test6.txt")
process_data() = raw_data |> read_lines .|> x->replace(x,"["=>"Any[") .|> Meta.parse .|> eval

sum_nums(x, y) = Any[x,y]
add_to_left!(x::Union{Vector,SubArray}, v) = @inbounds x[1] isa Int ? x[1] += v : add_to_left!(x[1], v)
add_to_left!(x::Union{Vector{Int},SubArray{T,U,Vector{Int}}}, v) where {T,U} = @inbounds x[1] += v
add_to_right!(x::Union{Vector,SubArray}, v) = @inbounds x[end] isa Int ? x[end] += v : add_to_right!(x[end], v)
add_to_right!(x::Union{Vector{Int},SubArray{T,U,Vector{Int}}}, v) where {T,U} = @inbounds x[end] += v

explode_in_level!(x) = explode_in_level!(x, 4)[1]
function explode_in_level!(x, d)
    d < 0 && return false, 0, 0
    @inbounds if d == 0 && (x isa Vector{Int} || (length(x) == 2 && x[1] isa Int && x[2] isa Int))
        return true, x[1], x[2] # return after first change
    end
    @inbounds for (i,v) in enumerate(x)
        any_change, v1, v2 = explode_in_level!(v, d-1)
        if any_change
            if d == 1   # replace only after the real explode
                x[i] = 0
            end
            if i > 1 && v1 != 0
                add_to_right!(@view(x[i-1:i-1]), v1)
                v1 = 0
            end
            if i < length(x) && v2 != 0
                add_to_left!(@view(x[i+1:i+1]), v2)
                v2 = 0
            end
            return true, v1, v2
        end
    end
    return false, 0, 0
end

function split_num!(x,i,v::Int)
    if v >= 10
        @inbounds x[i] = Any[v ÷ 2, sum(divrem(v, 2))]
        true
    else
        false
    end
end

split_num!(x,i,v::Vector) = split_num!(v) && return true
split_num!(x) = any(split_num!(x,i,v) for (i,v) in enumerate(x))

function reduce_num!(x)
    while true
        !any(op!->op!(x), [explode_in_level!, split_num!]) && break
    end
    x
end

calc_magnitude(x::Int) = x
calc_magnitude(x) = @inbounds calc_magnitude(x[1]) * 3 + calc_magnitude(x[2]) * 2
sum_reduce!(x, y) = reduce_num!(sum_nums(x,y))

function part1()
    data = process_data()
    res = reduce((x,y)->sum_reduce!(x,y), data)
    calc_magnitude(res)
end

function part2()
    data = process_data()
    max_magnitude = 0
    for (x,y) in permutations(data, 2)
        max_magnitude = max(max_magnitude, calc_magnitude(sum_reduce!(deepcopy(x),deepcopy(y))))
    end
    max_magnitude
end

end # module

if false
using BenchmarkTools
println(Day18.part1())
@btime Day18.part1()
Day18.submit(Day18.part1(), Day18.cur_day, 1)
println(Day18.part2())
@btime Day18.part2()
Day18.submit(Day18.part2(), Day18.cur_day, 2)
end
