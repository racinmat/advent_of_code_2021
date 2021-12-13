module Day12

using DrWatson
quickactivate(@__DIR__)
using DataStructures, StatsBase
using Pipe:@pipe
import Base: islowercase
include(projectdir("misc.jl"))

function edges2adjlist(edges)
    adjlist = DefaultDict(() -> [])
    for (node_from, node_to) in edges
        push!(adjlist[node_from], node_to)
        push!(adjlist[node_to], node_from)
    end
    adjlist
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
process_data() = @pipe raw_data |> read_lines .|> split(_, "-") |> edges2adjlist

islowercase(x::AbstractString) = all(islowercase.(collect(x)))
function count_paths_part1(adjlist, path)
    cur_node = last(path)
    # cur_node == "end" && return 1
    if cur_node == "end"
        # @info "found route" join(path,",")
        return 1
    end
    # next_node = adjlist[cur_node][2]
    a_res = 0
    for next_node in adjlist[cur_node]
        if all(islowercase.(collect(next_node))) && next_node ∈ path
            continue
        end
        a_res += count_paths_part1(adjlist, [path; next_node])
    end
    return a_res
end
# path = [path; next_node]

function count_paths_part2(adjlist, path)
    cur_node = last(path)
    # cur_node == "end" && return 1
    if cur_node == "end"
        # @info "found route" join(path,",")
        return 1
    end
    # next_node = adjlist[cur_node][2]
    a_res = 0
    for next_node in adjlist[cur_node]
        if islowercase(next_node)
            a_hist = filter(islowercase, [path; next_node]) |> countmap |> values |> countmap
            if haskey(a_hist, 3) || get(a_hist, 2, 0) >= 2 || next_node == "start"
                continue
            end
        end
        a_res += count_paths_part2(adjlist, [path; next_node])
    end
    return a_res
end

function part1()
    data = process_data()
    path = ["start"]
    adjlist = data
    count_paths_part1(adjlist, path)
end

function part2()
    data = process_data()
    path = ["start"]
    adjlist = data
    count_paths_part2(adjlist, path)
end


end # module

if false
println(Day12.part1())
Day12.submit(Day12.part1(), Day12.cur_day, 1)
println(Day12.part2())
Day12.submit(Day12.part2(), Day12.cur_day, 2)
end
