module Day03

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = raw_data |> read_lines .|> collect .|> (x->parse.(Bool, x)) |> x->hcat(x...)

function part1()
    data = process_data()
    bits = sum(data, dims=2) .> size(data, 2) / 2
    g_r = bits2num(bits)
    e_r = bits2num(.!bits)
    g_r * e_r
end

function filter_indices(data, comparison)
    idxs = trues(size(data, 2))
    cur_pos = 1
    while sum(idxs) > 1
        keep_bit = sum(view(data, cur_pos, idxs)) .>= sum(idxs) / 2
        @inbounds idxs[idxs] .&= comparison(view(data, cur_pos, idxs), keep_bit)
        cur_pos += 1
    end
    findfirst(idxs)
end

function part2()
    data = process_data()
    idx_o = filter_indices(data, .==)
    idx_c = filter_indices(data, .!=)
    o_r = bits2num(data[:, idx_o])
    c_r = bits2num(data[:, idx_c])
    c_r * o_r
end


end # module

if false
println(Day03.part1())
Day03.submit(Day03.part1(), Day03.cur_day, 1)
println(Day03.part2())
Day03.submit(Day03.part2(), Day03.cur_day, 2)
@btime Day03.part1()
@btime Day03.part2()
end
