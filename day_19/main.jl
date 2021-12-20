module Day19

using DrWatson
quickactivate(@__DIR__)
using Combinatorics, Rotations, Base.Iterators, Distances, DataStructures
using Pipe:@pipe
include(projectdir("misc.jl"))

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

function generate_possible_bases()
    angles = [0,pi,pi/2,3pi/2]
    map(reshape(product(angles,angles,angles) |> collect, :)) do (a,b,c)
        m = Matrix(RotXYZ(a,b,c))
        @. m[abs(m) <= eps(Float32)] = 0
        convert.(Int64, m)
    end |> unique
end

function beacon_pairs2dists(beacons1, beacons2, rel_base)
    beacons1_aligned = sortrows(hcat(beacons1, 1:size(beacons1,1)))
    beacons2_aligned = sortrows(hcat(beacons2 * rel_base, 1:size(beacons2,1)))
    dists1 = pairwise(dist, beacons1_aligned[:,1:3], dims=1)
    dists2 = pairwise(dist, beacons2_aligned[:,1:3], dims=1)
    dists1, dists2, beacons1_aligned, beacons2_aligned
end


function get_viable_bases(beacons1_base, beacons2_base)
    viable_bases = Matrix{Int64}[]
    for (i, base) in enumerate(generate_possible_bases())
        dists1, dists2, _, _ = beacon_pairs2dists(beacons1_base, beacons2_base, base)
        # if only 1 point intersects, we have no intersecting points
        length(intersect(dists1, dists2)) <= 2 && continue
        push!(viable_bases, base)
    end
    viable_bases
end

function match_pairs_in_dists(dists1, dists2)
    same_pairs = Vector{Int64}[]
    for (i,j) in product(1:size(dists1,1),1:size(dists2,2))
        length(intersect(dists1[i,:], dists2[j,:])) < 12 && continue
        push!(same_pairs, [i,j])
    end
    same_pairs
end

function find_viable_base(beacons1_base, beacons2_base)
    viable_bases = get_viable_bases(beacons1_base, beacons2_base)
    for base in viable_bases
        dists1, dists2, beacons1, beacons2 = beacon_pairs2dists(beacons1_base, beacons2_base, base)
        same_pairs = match_pairs_in_dists(dists1, dists2)
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

data = process_data()

# beacon_positions = data[1][2]
# trans_vec, base = find_viable_base(data[1][2], data[2][2])
# beacons2_proj2ref = trans_vec .+ data[2][2] * base
# beacon_positions = unique([beacon_positions[:,1:3]; beacons2_proj2ref], dims=1)
# trans_vec, base = find_viable_base(beacon_positions, data[3][2])
# trans_vec, base = find_viable_base(beacon_positions, data[4][2])
# beacons2_proj2ref = trans_vec .+ data[4][2] * base
# beacon_positions = unique([beacon_positions[:,1:3]; beacons2_proj2ref], dims=1)

function part1()
    data = process_data()
    beacon_positions = data[0]
    unprocessed_scanners = Queue{Int}()
    [enqueue!(unprocessed_scanners, x) for x in keys(data) if x != 0]
    unprocessed_scanners
    while !isempty(unprocessed_scanners)
        i = dequeue!(unprocessed_scanners)
        @info "examining scanner" i
        trans_vec, base = find_viable_base(beacon_positions, data[i])
        if isnothing(trans_vec) && isnothing(base)
            enqueue!(unprocessed_scanners, i)
            continue
        end
        beacons2_proj2ref = trans_vec .+ data[i] * base
        prev_len = size(beacon_positions, 1)
        beacon_positions = unique([beacon_positions; beacons2_proj2ref], dims=1)
        @info "processed beacon" i prev_len length(beacon_positions)
    end
    size(beacon_positions, 1)
end

function part2()
    data = process_data()
    beacon_positions = data[0]
    unprocessed_scanners = Queue{Int}()
    [enqueue!(unprocessed_scanners, x) for x in keys(data) if x != 0]
    unprocessed_scanners
    scanner_positions = [[0,0,0]]
    while !isempty(unprocessed_scanners)
        i = dequeue!(unprocessed_scanners)
        @info "examining scanner" i
        trans_vec, base = find_viable_base(beacon_positions, data[i])
        if isnothing(trans_vec) && isnothing(base)
            enqueue!(unprocessed_scanners, i)
            continue
        end
        beacons2_proj2ref = trans_vec .+ data[i] * base
        prev_len = size(beacon_positions, 1)
        beacon_positions = unique([beacon_positions; beacons2_proj2ref], dims=1)
        @info "processed beacon" i prev_len length(beacon_positions) trans_vec
        push!(scanner_positions, trans_vec[1,:])
    end
    pairwise(cityblock, scanner_positions) |> maximum
end


end # module

if false
println(Day19.part1())
Day19.submit(Day19.part1(), Day19.cur_day, 1)
println(Day19.part2())
Day19.submit(Day19.part2(), Day19.cur_day, 2)
end
