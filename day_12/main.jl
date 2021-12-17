module Day12

using DrWatson
quickactivate(@__DIR__)
using DataStructures, StatsBase
using Pipe:@pipe
import Base: islowercase
# using TimerOutputs, BenchmarkTools
include(projectdir("misc.jl"))

# const to = TimerOutput()
# reset_timer!(to)

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

islowercase(x::AbstractString) = all(islowercase(i) for i in x) # this is faster than collect and makes less allocations
# cur_node = "start"
function count_paths_part1(adjlist, a_path, cur_node)
    # cur_node == "end" && return 1
    if cur_node == "end"
        # @info "found route" join(path,",")
        return 1
    end
    # next_node = adjlist[cur_node][2]
    a_res = 0
    for next_node in adjlist[cur_node]
        #= @timeit to "islowercase_in_path" =# if next_node ∈ a_path
            continue
        end
        #= @timeit to "count_paths_part1" =# a_res += count_paths_part1(adjlist, 
            islowercase(next_node) ? union(a_path, [next_node]) : a_path, 
        next_node)
    end
    return a_res
end
# path = [path; next_node]
# path = new_path
# cur_node = next_node
# two_occur = Set{AbstractString}()
# originally there was list of visited nodes, then there was histogram of visited nodes
# which make few seconds of speedup, but using two sets went to ~50x speedup

function count_paths_part2(adjlist, one_occur, two_occur, cur_node)
    # cur_node == "end" && return 1
    if cur_node == "end"
        # @info "found route" join(path,",")
        return 1
    end
    # next_node = adjlist[cur_node][2]
    a_res = 0
    for next_node in adjlist[cur_node]
        if next_node == "start"
            continue
        end
        #= @timeit to "islowercase_etc" =# if islowercase(next_node)
            if next_node ∈ two_occur || (length(two_occur) == 1 && next_node ∈ one_occur)
                continue
            end
            #= @timeit to "count_paths_part2" =# if next_node ∉ two_occur && next_node ∉ one_occur
                a_res += count_paths_part2(adjlist, union(one_occur, [next_node]), two_occur, next_node)
            elseif next_node ∉ two_occur && next_node ∈ one_occur
                a_res += count_paths_part2(adjlist, one_occur, union(two_occur, [next_node]), next_node)
            else
                a_res += count_paths_part2(adjlist, one_occur, two_occur, next_node)
            end
        else
            #= @timeit to "count_paths_part2" =# a_res += count_paths_part2(adjlist, one_occur, two_occur, next_node)
        end
    end
    return a_res
end

function part1()
    #= @timeit to "process_data" =# adjlist = process_data()
    a_path = Set(["start"])
    #= @timeit to "count_paths_part1" =# count_paths_part1(adjlist, a_path, "start")
end

function part2()
    #= @timeit to "process_data" =# adjlist = process_data()
    one_occur = Set(["start"])
    #= @timeit to "count_paths_part2" =# count_paths_part2(adjlist, one_occur, Set{AbstractString}(), "start")
end


end # module

if false
using BenchmarkTools
Day12.reset_timer!(Day12.to)
println(Day12.part1())
show(Day12.to)
@btime Day12.part1()
Day12.submit(Day12.part1(), Day12.cur_day, 1)
Day12.reset_timer!(Day12.to)
println(Day12.part2())
show(Day12.to)
@btime Day12.part2()
Day12.submit(Day12.part2(), Day12.cur_day, 2)
end
