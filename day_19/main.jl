module Day19

using DrWatson
quickactivate(@__DIR__)
using Combinatorics, Rotations, Base.Iterators, Distances, DataStructures
using Pipe:@pipe
# using TimerOutputs, BenchmarkTools
include(projectdir("misc.jl"))

# const to = TimerOutput()
# reset_timer!(to)

parse_point(row) = @pipe row |> split(_, ",") |> parse.(Int, _)
function parse_scanner(scanner_lines)
    scanner, points... = scanner_lines
    m = match(r"--- scanner (\d+) ---", scanner)
    scanner_name = parse(Int, m[1])
    scanner_name, reduce(hcat, parse_point.(points))'
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
# const raw_data = cur_day |> read_file("input_test2.txt")

sortrows(A, rev=false) = sortslices(A, dims=1, by=x->(x[1], x[2], x[3]), rev=rev)

process_data() = @pipe(raw_data |> split(_, "\n\n")) .|> read_lines .|> parse_scanner |> Dict

const angles = [0,pi,pi/2,3pi/2]
const all_bases = map(reshape(product(angles,angles,angles) |> collect, :)) do (a,b,c)
    m = Matrix(RotXYZ(a,b,c))
    @. m[abs(m) <= eps(Float32)] = 0
    convert.(Int64, m)
end |> unique

function beacons2dists(beacons, rel_base = nothing)
    #= @timeit to "sortrows_beacon" =# beacons_aligned = sortrows(hcat(isnothing(rel_base) ? beacons : beacons * rel_base, 1:size(beacons,1)))
    #= @timeit to "pairwise" =# dists = pairwise(dist, @view(beacons_aligned[:,1:3]), dims=1)
    dists, beacons_aligned
end

function beacon_pairs2dists(beacons1, beacons2, b2key, rel_base, precomputed_dists)
    # I must compute beacons1 again every time, because the number of beacons is rising
    #= @timeit to "dists_beacon1" =# dists1, beacons1_aligned = beacons2dists(beacons1)
    # beacons2 are precomputed
    # @timeit to "dists_beacon2" dists2, beacons2_aligned = beacons2dists(beacons2, rel_base)
    #= @timeit to "dists_beacon2" =# dists2, beacons2_aligned = precomputed_dists[b2key][rel_base]
    dists1, dists2, beacons1_aligned, beacons2_aligned
end

function get_viable_bases(beacons1_base, beacons2_base, b2key, precomputed_dists)
    viable_bases = Matrix{Int64}[]
    #= @timeit to "dists_beacon1" =# dists1, _ = beacons2dists(beacons1_base)
    #= @timeit to "dists1set" =# dists1set = Set(dists1)
    for (i, base) in enumerate(all_bases)
        #= @timeit to "dists_beacon2" =# dists2, _ = precomputed_dists[b2key][base]
        # if only 1 point intersects, we have no intersecting points
        #= @timeit to "intersect_all_dists" =# length(intersect(dists1set, dists2)) <= 2 && continue
        push!(viable_bases, base)
    end
    viable_bases
end

function match_pairs_in_dists(dists1, dists2)
    same_pairs = Vector{Int64}[]
    dists1rows = [Set(i) for i in eachrow(dists1)]
    dists2rows = [Set(i) for i in eachrow(dists2)]
    for (i,j) in product(1:size(dists1,1),1:size(dists2,2))
        #= @timeit to "intersect_rows" =# length(intersect(dists1rows[i], dists2rows[j])) < 12 && continue
        push!(same_pairs, [i,j])
    end
    same_pairs
end

# beacons1_base, beacons2_base = beacon_positions, data[i]
function find_viable_base(beacons1_base, beacons2_base, b2key, precomputed_dists)
    #= @timeit to "get_viable_bases" =# viable_bases = get_viable_bases(beacons1_base, beacons2_base, b2key, precomputed_dists)
    # base = viable_bases[1]
    #= @timeit to "dists_beacon1" =# dists1, beacons1 = beacons2dists(beacons1_base)
    for base in viable_bases
        #= @timeit to "dists_beacon2" =# dists2, beacons2 = precomputed_dists[b2key][base]
        #= @timeit to "match_pairs_in_dists" =# same_pairs = match_pairs_in_dists(dists1, dists2)
        length(same_pairs) < 12 && continue    
        # init with first scanner results, then add the rest
        beacon1_rows = getindex.(same_pairs, 1)
        beacon2_rows = getindex.(same_pairs, 2)
        
        trans_vecs = unique(beacons1[beacon1_rows,1:3] - beacons2[beacon2_rows,1:3], dims=1)
        size(trans_vecs) != (1,3) && continue
        return trans_vecs, base
    end
    return nothing, nothing
end

# weighted cityblock is sum(abs(x - y) .* w)
# when assuming max distances are not too large, I can sum uniquely distances 
# in different dimensions so the result is single number
dist = WeightedCityblock([1_000_000,1_000,1])
# dist = WeightedCityblock([100,10,1])
function keys2unprocessed_scanners(data)
    unprocessed_scanners = Queue{Int}()
    [enqueue!(unprocessed_scanners, x) for x in data if x != 0]
    unprocessed_scanners
end

function process_scanners(f, unprocessed_scanners, beacon_positions, data, precomputed_dists)
    while !isempty(unprocessed_scanners)
        i = dequeue!(unprocessed_scanners)
        # @info "examining scanner" i
        #= @timeit to "find_viable_base" =# trans_vec, base = find_viable_base(beacon_positions, data[i], i, precomputed_dists)
        if isnothing(trans_vec) && isnothing(base)
            enqueue!(unprocessed_scanners, i)
            continue
        end
        beacons2_proj2ref = trans_vec .+ data[i] * base
        # prev_len = size(beacon_positions, 1)
        beacon_positions = f(unique([beacon_positions; beacons2_proj2ref], dims=1), trans_vec)
        # @info "processed beacon" i prev_len length(beacon_positions)
    end
    beacon_positions
end

precompute_rel_base_dists(data) = Dict(k=>Dict(b=>beacons2dists(beacons, b) for b in all_bases) for (k, beacons) in data)

function part1()
    data = process_data()
    beacon_positions = data[0]
    #= @timeit to "precompute_rel_base_dists" =# precomputed_dists = precompute_rel_base_dists(data)
    unprocessed_scanners = keys2unprocessed_scanners(keys(data))
    beacon_positions = process_scanners(unprocessed_scanners, beacon_positions, data, precomputed_dists) do merged_beacons, _
        merged_beacons
    end
    size(beacon_positions, 1)
end

function part2()
    data = process_data()
    beacon_positions = data[0]
    #= @timeit to "precompute_rel_base_dists" =# precomputed_dists = precompute_rel_base_dists(data)
    unprocessed_scanners = keys2unprocessed_scanners(keys(data))
    scanner_positions = [[0,0,0]]
    beacon_positions = process_scanners(unprocessed_scanners, beacon_positions, data, precomputed_dists) do merged_beacons, trans_vec
        push!(scanner_positions, trans_vec[1,:])
        merged_beacons
    end
    pairwise(cityblock, scanner_positions) |> maximum
end


end # module

if false
using BenchmarkTools
Day19.reset_timer!(Day19.to)
println(Day19.part1())
show(Day19.to)
@btime Day19.part1()
Day19.submit(Day19.part1(), Day19.cur_day, 1)
println(Day19.part2())
Day19.submit(Day19.part2(), Day19.cur_day, 2)
end
