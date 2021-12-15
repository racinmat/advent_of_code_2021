module Day08

using DrWatson
quickactivate(@__DIR__)
using Base.Iterators
using BenchmarkTools, TimerOutputs
include(projectdir("misc.jl"))
parse_row(x) = split(x, " | ") .|> x->split(x, " ")

const to = TimerOutput()
reset_timer!(to)

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
# const raw_data = cur_day |> read_file("input_test2.txt")
process_data() = raw_data |> read_lines .|> parse_row

function part1()
    data = process_data()
    outputs = getindex.(data, 2)
    sum(count(x->length(x) ∈ [2,3,4,7], i) for i in outputs)
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
const num2seg = Dict(v=>k for (k,v) in seg2num)
const num2seg_len = Dict(k=>length(v) for (k,v) in num2seg)

function solve_row(pattern, output)
    @timeit to "in_numbers" in_numbers = Dict(k-1=>v for (k,v) in enumerate(@.(pattern |> collect |> sort |> join)))
    @timeit to "out_numbers" out_numbers = @.(output |> collect |> sort |> join)
    # in_numbers has always 10 elements, 1 for each number, I don't need to map individual segments
    # I can map indices directly to numbers, here I'm grouping them by same lengths

    mapping = Dict(i => [k for (k, v) in num2seg_len if v == length(in_numbers[i])] for i in 0:9)
    three = findfirst(x->length(x) == 5 && length(setdiff(x, in_numbers[findfirst(==([1]),mapping)])) == 3, filter((kv)->length(mapping[kv[1]]) > 1, in_numbers))
    mapping[three] = [3]
    for k in keys(mapping)
        k == three && continue
        mapping[k] = setdiff(mapping[k], 3)
    end
    mapping

    nine = findfirst(x->length(x) == 6 && length(setdiff(x, in_numbers[findfirst(==([4]),mapping)])) == 2, filter((kv)->length(mapping[kv[1]]) > 1, in_numbers))
    mapping[nine] = [9]
    for k in keys(mapping)
        k == nine && continue
        mapping[k] = setdiff(mapping[k], 9)
    end
    mapping

    zero = findfirst(x->length(x) == 6 && length(setdiff(x, in_numbers[findfirst(==([7]),mapping)])) == 3, filter((kv)->length(mapping[kv[1]]) > 1, in_numbers))
    mapping[zero] = [0]
    for k in keys(mapping)
        k == zero && continue
        mapping[k] = setdiff(mapping[k], 0)
    end
    mapping

    five = findfirst(x->length(x) == 5 && length(setdiff(in_numbers[findfirst(==([6]),mapping)], x)) == 1, filter((kv)->length(mapping[kv[1]]) > 1, in_numbers))
    mapping[five] = [5]
    for k in keys(mapping)
        k == five && continue
        mapping[k] = setdiff(mapping[k], 5)
    end
    solution = Dict(k=>v[1] for (k,v) in mapping)
    sol_mapping = Dict(v=>solution[k] for (k,v) in in_numbers)
    reduce((a,b)->a*10+b, getindex.(Ref(sol_mapping), out_numbers))
end
# sol = mapping
# mapping = mapping_try
function solve_options(is_valid, mapping)
    if all(kv->length(kv[2]) == 1, mapping)
        return Dict(k=>v[1] for (k, v) in mapping), length(unique(values(mapping))) == length(mapping)
    end
    a_letter, options = filter(kv->length(kv[2])>1, mapping) |> first
    i = 1
    @timeit to "all_options" @inbounds for i in 1:length(options)
        mapping_try = copy(mapping)
        mapping_try[a_letter] = options[i:i]
        solution_valid = true
        @timeit to "setdiff" @inbounds for k in setdiff(keys(mapping_try), Set(a_letter))
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

function solve_options2(is_valid, mapping)
    if all(kv->length(kv[2]) == 1, mapping)
        return Dict(k=>v[1] for (k, v) in mapping), length(unique(values(mapping))) == length(mapping)
    end
    a_letter, options = filter(kv->length(kv[2])>1, mapping) |> first
    @timeit to "all_options" @inbounds for i in 1:length(options)
        mapping_try = copy(mapping)
        mapping_try[a_letter] = options[i:i]
        solution_valid = true
        @timeit to "setdiff" @inbounds for k in setdiff(keys(mapping_try), Set(a_letter))
            mapping_try[k] = setdiff(mapping_try[k], mapping_try[a_letter])
            if isempty(mapping_try[k])
                solution_valid = false
            end
        end
        !solution_valid && continue
        res, was_success = solve_options2(is_valid, mapping_try)
        was_success && is_valid(res) && return res, was_success
    end
    mapping, false
end
function part2()
    data = process_data()
    (pattern, output) = data[1]
    sum(solve_row(pattern, output) for (pattern, output) in data)
end


end # module

if false
using BenchmarkTools
println(Day08.part1())
@btime Day08.part1()
@btime Day08.part1()
Day08.submit(Day08.part1(), Day08.cur_day, 1)
Day08.reset_timer!(Day08.to)
println(Day08.part2())
show(Day08.to)
@btime Day08.part2()
Day08.submit(Day08.part2(), Day08.cur_day, 2)
end
