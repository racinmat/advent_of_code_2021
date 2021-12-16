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

#  ──────────────────────────────────────────────────────────────────────────────────────────────────────────
#                                                                    Time                   Allocations
#                                                            ──────────────────────   ───────────────────────
#                      Tot / % measured:                          16.2s / 100%            29.5GiB / 100%

#  Section                                           ncalls     time   %tot     avg     alloc   %tot      avg
#  ──────────────────────────────────────────────────────────────────────────────────────────────────────────
#  count_paths_part2                                      3    16.2s   100%   5.38s   29.5GiB  100%   9.85GiB
#    count_paths_part2                                   11    16.2s   100%   1.47s   29.5GiB  100%   2.69GiB
#      count_paths_part2                                 45    16.1s   100%   359ms   29.5GiB  100%    672MiB
#        count_paths_part2                              170    16.1s   100%  95.0ms   29.5GiB  100%    178MiB
#          count_paths_part2                            646    16.1s   100%  25.0ms   29.5GiB  100%   46.8MiB
#            count_paths_part2                        2.22k    16.1s   100%  7.24ms   29.4GiB  100%   13.6MiB
#              count_paths_part2                      6.79k    15.9s  98.6%  2.34ms   29.1GiB  98.4%  4.38MiB
#                count_paths_part2                    17.7k    15.3s  95.0%   867μs   27.9GiB  94.4%  1.61MiB
#                  count_paths_part2                  39.4k    13.9s  86.4%   354μs   25.2GiB  85.2%   670KiB
#                    count_paths_part2                69.9k    11.3s  69.8%   161μs   19.7GiB  66.8%   296KiB
#                      count_paths_part2              96.6k    7.64s  47.3%  79.1μs   12.9GiB  43.5%   140KiB
#                        count_paths_part2            88.8k    3.76s  23.3%  42.3μs   5.67GiB  19.2%  66.9KiB
#                          count_paths_part2          60.4k    1.94s  12.0%  32.2μs   2.88GiB  9.75%  50.0KiB
#                            islowercase_etc           139k    1.09s  6.75%  7.83μs   1.78GiB  6.04%  13.4KiB
#                              a_hist                  124k    1.02s  6.34%  8.23μs   1.78GiB  6.04%  15.0KiB
#                            count_paths_part2        29.2k    708ms  4.39%  24.3μs   1.07GiB  3.64%  38.6KiB
#                              islowercase_etc        63.4k    520ms  3.22%  8.20μs    869MiB  2.87%  14.0KiB
#                                a_hist               59.7k    488ms  3.02%  8.17μs    869MiB  2.87%  14.9KiB
#                              count_paths_part2      9.31k    135ms  0.83%  14.5μs    219MiB  0.72%  24.1KiB
#                                islowercase_etc      14.1k    124ms  0.77%  8.79μs    216MiB  0.71%  15.7KiB
#                                  a_hist             14.1k    117ms  0.72%  8.29μs    216MiB  0.71%  15.7KiB
#                                count_paths_part2    1.64k    634μs  0.00%   386ns    410KiB  0.00%     256B
#                          islowercase_etc             228k    1.60s  9.92%  7.03μs   2.75GiB  9.30%  12.6KiB
#                            a_hist                    198k    1.50s  9.27%  7.56μs   2.75GiB  9.30%  14.6KiB
#                        islowercase_etc               300k    3.57s  22.1%  11.9μs   7.15GiB  24.2%  25.0KiB
#                          a_hist                      256k    3.42s  21.2%  13.4μs   7.15GiB  24.2%  29.4KiB
#                      islowercase_etc                 237k    3.29s  20.4%  13.9μs   6.86GiB  23.2%  30.3KiB
#                        a_hist                        183k    3.17s  19.6%  17.3μs   6.86GiB  23.2%  39.2KiB
#                    islowercase_etc                   143k    2.42s  15.0%  16.9μs   5.40GiB  18.3%  39.6KiB
#                      a_hist                          109k    2.34s  14.5%  21.5μs   5.40GiB  18.3%  52.1KiB
#                  islowercase_etc                    66.5k    1.23s  7.64%  18.6μs   2.71GiB  9.16%  42.7KiB
#                    a_hist                           46.6k    1.20s  7.42%  25.7μs   2.71GiB  9.16%  60.9KiB
#                islowercase_etc                      26.7k    523ms  3.24%  19.6μs   1.19GiB  4.03%  46.7KiB
#                  a_hist                             19.1k    507ms  3.14%  26.6μs   1.19GiB  4.03%  65.5KiB
#              islowercase_etc                        8.91k    159ms  0.98%  17.8μs    356MiB  1.18%  41.0KiB
#                a_hist                               5.74k    154ms  0.95%  26.8μs    356MiB  1.18%  63.6KiB
#            islowercase_etc                          2.67k   36.5ms  0.23%  13.7μs   97.7MiB  0.32%  37.5KiB
#              a_hist                                 1.83k   34.6ms  0.21%  18.9μs   97.7MiB  0.32%  54.7KiB
#          islowercase_etc                              711   6.96ms  0.04%  9.79μs   18.1MiB  0.06%  26.1KiB
#            a_hist                                     426   6.49ms  0.04%  15.2μs   18.1MiB  0.06%  43.6KiB
#        islowercase_etc                                186   2.39ms  0.01%  12.8μs   6.18MiB  0.02%  34.0KiB
#          a_hist                                       132   2.23ms  0.01%  16.9μs   6.18MiB  0.02%  48.0KiB
#      islowercase_etc                                   49    498μs  0.00%  10.2μs   1.47MiB  0.00%  30.7KiB
#        a_hist                                          27    466μs  0.00%  17.3μs   1.47MiB  0.00%  55.8KiB
#    islowercase_etc                                     14    248μs  0.00%  17.7μs    473KiB  0.00%  33.8KiB
#      a_hist                                            11    230μs  0.00%  20.9μs    472KiB  0.00%  42.9KiB
#  islowercase_etc                                        3   38.6μs  0.00%  12.9μs   50.2KiB  0.00%  16.7KiB
#    a_hist                                               1   24.6μs  0.00%  24.6μs   49.4KiB  0.00%  49.4KiB
#  ──────────────────────────────────────────────────────────────────────────────────────────────────────────
