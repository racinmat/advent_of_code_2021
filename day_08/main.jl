module Day08

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))
parse_row(x) = split(x, " | ") .|> x->split(x, " ")

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
# const raw_data = cur_day |> read_file("input_test2.txt")
process_data() = raw_data |> read_lines .|>parse_row
# todo: you may 
function part1()
    data = process_data()
    outputs = getindex.(data, 2)
    count.(x -> length(x) ∈ [2,3,4,7], outputs) |> sum
end

const seg2num = Dict(
    "abcdef" => 0,
    "bc" => 1,
    "abdeg" => 2,
    "abcdg" => 3,
    "bcfg" => 4,
    "acdfg" => 5,
    "acdefg" => 6,
    "abc" => 7,
    "abcdefg" => 8,
    "abcdfg" => 9,
)
num2seg = Dict(v=>k for (k,v) in seg2num)

function solve_row(pattern, output)
    in_numbers = @.(pattern |> collect |> sort |> join)
    out_numbers = @.(output |> collect |> sort |> join)
    mapping = Dict{Char,Union{Vector{Char},Nothing}}(i => collect("abcdefg") for i in collect("abcdefg"))
    # searching for simple numbers
    for i in [1,4,7,8]
        comb = filter(x->length(x)==length(num2seg[i]), in_numbers) |> first
        for j in collect(comb)
            mapping[j] = intersect(mapping[j], collect(num2seg[i]))
        end
    end
    solution, _ = solve_options(mapping) do sol
        all(x->join(sort(getindex.(Ref(sol), collect(x)))) ∈ keys(seg2num), in_numbers)
    end
    nums = map(x->seg2num[join(sort(getindex.(Ref(solution), collect(x))))], out_numbers)
    reduce((a,b)->a*10+b, nums)
end

function solve_options(is_valid, mapping)
    if all(kv->length(kv[2]) == 1, mapping)
        return Dict(k=>v[1] for (k, v) in mapping), length(unique(values(mapping))) == length(mapping)
    end
    a_letter, options = filter(kv->length(kv[2])>1, mapping) |> first
    @inbounds for i in 1:length(options)
        mapping_try = copy(mapping)
        mapping_try[a_letter] = options[i:i]
        solution_valid = true
        @inbounds for k in setdiff(keys(mapping_try), Set(a_letter))
            mapping_try[k] = setdiff(mapping_try[k], mapping_try[a_letter])
            if isempty(mapping_try[k])
                solution_valid = false
            end
        end
        !solution_valid && continue
        res, was_success = solve_options(is_valid, mapping_try)
        was_success && is_valid(res) && return res, was_success
    end
    mapping, false
end

function part2()
    data = process_data()
    sum(solve_row(pattern, output) for (pattern, output) in data)
end


end # module

if false
using BenchmarkTools
println(Day08.part1())
@btime Day08.part1()
Day08.submit(Day08.part1(), Day08.cur_day, 1)
println(Day08.part2())
@btime Day08.part2()
Day08.submit(Day08.part2(), Day08.cur_day, 2)
end
