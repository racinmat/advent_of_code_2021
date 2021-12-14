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
process_data() = raw_data |> read_lines .|>parse_row

function part1()
    data = process_data()
    outputs = getindex.(data, 2)
    sum(count(x->length(x) ∈ [2,3,4,7], i) for i in outputs)
    @btime sum(count(x->length(x) ∈ [2,3,4,7], i) for i in outputs)
    @btime count(length(x) ∈ [2,3,4,7] for x in Iterators.flatten(outputs))
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
    using StatsBase
    length.(keys(seg2num)) |> countmap
    @timeit to "in_numbers" in_numbers = Dict(k-1=>v for (k,v) in enumerate(@.(pattern |> collect |> sort |> join)))
    @timeit to "out_numbers" out_numbers = @.(output |> collect |> sort |> join)
    # in_numbers has always 10 elements, 1 for each number, I don't need to map individual segments
    # I can map indices directly to numbers, here I'm grouping them by same lengths
    mapping = Dict(i => [k for (k, v) in num2seg_len if v == length(in_numbers[i])] for i in 0:9)

    solution, _ = solve_options2(mapping) do sol
        # todo: dodělat
        all(x->join(sort(getindex.(Ref(sol), collect(x)))) ∈ keys(seg2num), in_numbers)
        in_numbers
        sol
        all(kv->join(sort(getindex.(Ref(sol), collect(kv[1])))) ∈ keys(seg2num), in_numbers)
        map(kv->join(sort(getindex.(Ref(sol), collect(kv[1])))) ∈ keys(seg2num), collect(in_numbers))
        [num2seg[sol[k][1]] for (k,v) in in_numbers]

    end
    nums = map(x->seg2num[join(sort(getindex.(Ref(solution), collect(x))))], out_numbers)
    reduce((a,b)->a*10+b, nums)
end
sol = mapping
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
# 261
@btime Day08.part1()
Day08.submit(Day08.part1(), Day08.cur_day, 1)
Day08.reset_timer!(Day08.to)
println(Day08.part2())
show(Day08.to)
# 987553
@btime Day08.part2()
Day08.submit(Day08.part2(), Day08.cur_day, 2)
end

# ────────────────────────────────────────────────────────────────────────────────
# Time                   Allocations
# ──────────────────────   ───────────────────────
# Tot / % measured:             287ms / 98.0%            136MiB / 98.9%

# Section                 ncalls     time   %tot     avg     alloc   %tot      avg
# ────────────────────────────────────────────────────────────────────────────────
# all_options                200    271ms  96.2%  1.35ms    130MiB  96.9%   666KiB
#   all_options              574    264ms  93.9%   460μs    127MiB  94.5%   226KiB
#     all_options          1.70k    248ms  88.2%   146μs    118MiB  87.8%  71.2KiB
#       all_options        3.96k    210ms  74.8%  53.1μs   95.8MiB  71.4%  24.8KiB
#         all_options      4.59k    113ms  40.0%  24.5μs   52.3MiB  39.0%  11.7KiB
#           setdiff        10.5k   53.3ms  19.0%  5.06μs   32.8MiB  24.4%  3.19KiB
#           all_options      815   40.9ms  14.5%  50.1μs   8.09MiB  6.02%  10.2KiB
#             setdiff      1.59k   33.8ms  12.0%  21.3μs   4.94MiB  3.68%  3.19KiB
#         setdiff          10.6k   54.5ms  19.4%  5.16μs   32.9MiB  24.5%  3.19KiB
#       setdiff            5.29k   28.2ms  10.0%  5.34μs   16.6MiB  12.3%  3.21KiB
#     setdiff              1.99k   11.4ms  4.05%  5.72μs   6.28MiB  4.67%  3.23KiB
#   setdiff                  574   3.70ms  1.31%  6.44μs   1.84MiB  1.37%  3.28KiB
# filtering 1478             200   8.60ms  3.06%  43.0μs   3.04MiB  2.26%  15.6KiB
# in_numbers                 200   1.44ms  0.51%  7.21μs    775KiB  0.56%  3.88KiB
# out_numbers                200    596μs  0.21%  2.98μs    316KiB  0.23%  1.58KiB
# ────────────────────────────────────────────────────────────────────────────────
