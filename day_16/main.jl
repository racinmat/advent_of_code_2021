module Day16

using DrWatson
quickactivate(@__DIR__)
using Pipe:@pipe
using Base.Iterators
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
# const raw_data = cur_day |> read_file("input_test2.txt")
# const raw_data = cur_day |> read_file("input_test3.txt")
# const raw_data = cur_day |> read_file("input_test4.txt")
process_data() = @pipe raw_data |> collect .|> parse(Int, _, base=16) .|> string(_, base=2, pad=4) .|> 
    collect |> Iterators.flatten .|> parse(Bool, _)

function parse_literal_value(bits)
    value = 0
    for (i, val) in enumerate(Iterators.partition(bits, 5))
        value = value * 16 + bits2num(val[2:end])
        if val[1] == 0
            return value, bits[i*5+1:end]
        end
    end
end

function parse_packet(bits)
    if length(bits) < 7
        return nothing, nothing, nothing
    end
    version = bits2num(bits[1:3])
    tid = bits2num(bits[4:6])
    version_sum = version
    if tid == 4
        number, remainder = parse_literal_value(bits[7:end])
        return version_sum, number, remainder
    else
        ltid = bits2num(bits[7])
        vals = []
        remainder = if ltid == 1
            num_subpackets = bits2num(bits[8:8+11-1])
            sub_packets = bits[8+11:end]
            for i in 1:num_subpackets
                a_version, val, sub_packets = parse_packet(sub_packets)
                version_sum += a_version
                push!(vals, val)
            end
            sub_packets
        else
            total_length = bits2num(bits[8:8+15-1])
            sub_packets = bits[8+15:8+15+total_length-1]
            while length(sub_packets) > 0
                a_version, val, sub_packets = parse_packet(sub_packets)
                version_sum += a_version
                push!(vals, val)
            end
            bits[8+15+total_length:end]
        end
        res_val = if tid == 0
            sum(vals)
        elseif tid == 1
            prod(vals)
        elseif tid == 2
            minimum(vals)
        elseif tid == 3
            maximum(vals)
        elseif tid == 5
            vals[1] > vals[2]
        elseif tid == 6
            vals[1] < vals[2]
        elseif tid == 7
            vals[1] == vals[2]
        end
        return version_sum, res_val, remainder
    end
end

function part1()
    bits = process_data()
    version_sum, _, _ = parse_packet(bits)
    version_sum
end

function part2()
    bits = process_data()
    _, res_val, _ = parse_packet(bits)
    res_val
end


end # module

if false
println(Day16.part1())
Day16.submit(Day16.part1(), Day16.cur_day, 1)
println(Day16.part2())
Day16.submit(Day16.part2(), Day16.cur_day, 2)
end
