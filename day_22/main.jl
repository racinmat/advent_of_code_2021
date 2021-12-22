module Day22

using DrWatson
quickactivate(@__DIR__)
using Base.Iterators
using Combinatorics
import Base: Dict
include(projectdir("misc.jl"))

function parse_row(row)
    m = match(r"(\w+) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)", row)
    m[1], parse.(Int, m.captures[2:7])
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
# const raw_data = cur_day |> read_input
const raw_data = cur_day |> read_file("input_test.txt")
# const raw_data = cur_day |> read_file("input_test2.txt")
process_data() = raw_data |> read_lines .|> parse_row

struct Cuboid
    x::UnitRange{Int}
    y::UnitRange{Int}
    z::UnitRange{Int}
    Cuboid(x,y,z) = x.stop < x.start || y.stop < y.start || z.stop < z.start ? error("Ranges out of order") : new(x,y,z)
end
Dict(x::Cuboid) = Dict(fn=>getfield(x, fn) for fn ∈ propertynames(x))
Cuboid(d::Dict) = Cuboid(d[:x], d[:y], d[:z])

# because I want 11:12 and 13:13 not to be disjoint
are_disjoint(x1::UnitRange, x2::UnitRange) = maximum(x1) < (minimum(x2) - 1) || maximum(x2) < (minimum(x1) - 1)
any_intersection(c1::Cuboid, c2::Cuboid) = !are_disjoint(c1.x, c2.x) && !are_disjoint(c1.y, c2.y) && !are_disjoint(c1.z, c2.z)
# next to each other in single dimension, same in 2 dimensions, can merge
function are_neighboring(c1::Cuboid, c2::Cuboid)
    dims_align = Dict(i=>getfield(c1, i) == getfield(c2, i) for i in [:x, :y, :z])
    num_dims_align = dims_align |> values |> sum
    if num_dims_align != 2
        return false
    end
    d = findfirst(==(0), dims_align)
    # they are disjoint
    return !are_disjoint(getfield(c1, d), getfield(c2, d))
end

function reduce_followings(c_res)
    c_res_reduced = Cuboid[]
    # i=4
    skip_next = false
    for i in 1:length(c_res)-1
        # @info "reducing" i c_res[i] c_res[i+1] are_neighboring(c_res[i], c_res[i+1]) skip_next
        if skip_next
            skip_next = false
            continue
        end
        if are_neighboring(c_res[i], c_res[i+1])
            append!(c_res_reduced, do_union(c_res[i], c_res[i+1]))
            skip_next = true
        else
            push!(c_res_reduced, c_res[i])
        end
    end
    # if this is false at the end, I did not merge last element
    if !skip_next
        push!(c_res_reduced, last(c_res))
    end
    c_res_reduced
end

function reduce_pairs(c_res)
    all_pairs = combinations(c_res, 2)
    unprocessed = Set(c_res)
    c_res_reduced = Cuboid[]
    for (i,j) in all_pairs
        if i ∈ unprocessed && j ∈ unprocessed && are_neighboring(i, j)
            append!(c_res_reduced, do_union(i, j))
            delete!(unprocessed, i)
            delete!(unprocessed, j)
        end
    end
    c_res_reduced
    append!(c_res_reduced, unprocessed)
    c_res_reduced
end

function do_union(c1::Cuboid, c2::Cuboid)
    # they are same
    dims_align = Dict(i=>getfield(c1, i) == getfield(c2, i) for i in [:x, :y, :z])
    num_dims_align = dims_align |> values |> sum
    if num_dims_align == 3
        return [c1]
    # they are disjoint
    elseif !any_intersection(c1, c2)
        return [c1, c2]
    # are aligned in 2 dims
    elseif num_dims_align == 2
        d = findfirst(==(0), dims_align)
        # they are disjoint
        if are_disjoint(getfield(c1, d), getfield(c2, d))
            return [c1, c2]
        # they are not disjoint, so we can merge it to one
        else
            r_res = min(minimum(getfield(c1, d)), minimum(getfield(c2, d))):max(maximum(getfield(c1, d)), maximum(getfield(c2, d)))
            if d == :x
                return [Cuboid(r_res, c1.y, c1.z)]
            elseif d == :y
                return [Cuboid(c1.x, r_res, c1.z)]
            elseif d == :z
                return [Cuboid(c1.x, c1.y, r_res)]
            end
        end
    elseif num_dims_align == 1
        # 1 dimension alings, so now I deal with problem only in plane
        # nothing is disjoint, so they overlap
        # I take the c1 as reference and split c2 to multiple cuboids
        d = findfirst(==(1), dims_align)
        c_res = [c1]
        # the one aligning dimension is special case for simpler debugging
        if d == :x
            y_low = c2.y.start:(c1.y.start-1)
            y_high = (c1.y.stop+1):c2.y.stop
            z_same = c1.z.start:c2.z.stop
            z_low = c2.z.start:(c1.z.start-1)
            z_high = (c1.z.stop+1):c2.z.stop
            y_same = c1.y.start:c2.y.stop
            # all pairs, validate for them
            all_pairs = [(y,z) for (y,z)
                in reshape(product([y_low,y_same,y_high], [z_low,z_same,z_high]) |> collect, :)
                if (y,z) != (y_same, z_same)]
            for (y_ran, z_ran) in all_pairs
                if y_ran.start <= y_ran.stop && z_ran.start <= z_ran.stop
                    push!(c_res, Cuboid(c2.x, y_ran, z_ran))
                end
            end
            return reduce_pairs(c_res)
        elseif d == :y
            x_low = c2.x.start:(c1.x.start-1)
            x_high = (c1.x.stop+1):c2.x.stop
            z_same = c1.z.start:c2.z.stop
            z_low = c2.z.start:(c1.z.start-1)
            z_high = (c1.z.stop+1):c2.z.stop
            x_same = c1.x.start:c2.x.stop
            # all pairs, validate for them
            all_pairs = [(x,z) for (x,z)
                in reshape(product([x_low,x_same,x_high], [z_low,z_same,z_high]) |> collect, :)
                if (x,z) != (x_same, z_same)]
            for (x_ran, z_ran) in all_pairs
                if x_ran.start <= x_ran.stop && z_ran.start <= z_ran.stop
                    push!(c_res, Cuboid(x_ran, c2.y, z_ran))
                end
            end
            return reduce_pairs(c_res)
        elseif d == :z
            x_low = c2.x.start:(c1.x.start-1)
            x_same = c1.x.start:c2.x.stop
            x_high = (c1.x.stop+1):c2.x.stop
            y_low = c2.y.start:(c1.y.start-1)
            y_same = c1.y.start:c2.y.stop
            y_high = (c1.y.stop+1):c2.y.stop
            # all pairs, validate for them
            all_pairs = [(x,y) for (x,y)
                in reshape(product([x_low,x_same,x_high], [y_low,y_same,y_high]) |> collect, :)
                if (x,y) != (x_same, y_same)]
            for (x_ran, y_ran) in all_pairs
                if x_ran.start <= x_ran.stop && y_ran.start <= y_ran.stop
                    push!(c_res, Cuboid(x_ran, y_ran, c2.z))
                end
            end
            return reduce_pairs(c_res)
        end
    else
        c_res = [c1]
        x_low = c2.x.start:(c1.x.start-1)
        x_same = max(c1.x.start,c2.x.start):min(c1.x.stop,c2.x.stop)
        x_high = (c1.x.stop+1):c2.x.stop
        y_low = c2.y.start:(c1.y.start-1)
        y_same = max(c1.y.start,c2.y.start):min(c1.y.stop,c2.y.stop)
        y_high = (c1.y.stop+1):c2.y.stop
        z_low = c2.z.start:(c1.z.start-1)
        z_same = max(c1.z.start,c2.z.start):min(c1.z.stop,c2.z.stop)
        z_high = (c1.z.stop+1):c2.z.stop
        # all pairs, validate for them
        all_pairs = [(x,y,z) for (x,y,z)
            in reshape(product([x_low,x_same,x_high], [y_low,y_same,y_high], [z_low,z_same,z_high]) |> collect, :)
            if (x,y,z) != (x_same, y_same, z_same)]
        for (x_ran, y_ran, z_ran) in all_pairs
            if x_ran.start <= x_ran.stop && y_ran.start <= y_ran.stop && z_ran.start <= z_ran.stop
                push!(c_res, Cuboid(x_ran, y_ran, z_ran))
            end
        end
        return reduce_pairs(c_res)
    end
end

function do_union(cs::Vector{Cuboid}, c2::Cuboid)
    cs_res = Cuboid[]
    did_intersect = false
    # c = cs[1]
    for c in cs
        if any_intersection(c, c2)
            # c1 = c
            a_res = do_union(c, c2)
            # @info "checking mergeability" sum(are_neighboring(i,j) for (i,j) in combinations(a_res, 2))
            append!(cs_res, a_res)
            did_intersect = true
        else
            push!(cs_res, c)
        end
    end
    if !did_intersect
        push!(cs_res, c2)
    end
    # sometimes I can merge multiple times at once
    cs_res |> reduce_pairs |> reduce_followings
end

function diff(c1::Cuboid, c2::Cuboid)
    # geometric c1 - c2
    # they are same
    dims_align = Dict(i=>getfield(c1, i) == getfield(c2, i) for i in [:x, :y, :z])
    num_dims_align = dims_align |> values |> sum
    if num_dims_align == 3
        return []
    # they are disjoint
    elseif are_disjoint(c1.x, c2.x) || are_disjoint(c1.y, c2.y) || are_disjoint(c1.z, c2.z)
        return [c1]
    # are aligned in 2 dims
    elseif num_dims_align == 2
        d = findfirst(==(0), dims_align)
        # they are disjoint
        if are_disjoint(getfield(c1, d), getfield(c2, d))
            return [c1]
        # they are not disjoint, so we can merge it to one
        else
            if getfield(c1, d).start < getfield(c2, d).start && getfield(c1, d).stop <= getfield(c2, d).stop
                r_res = getfield(c1, d).start:min(getfield(c1, d).stop, getfield(c2, d).start)
                if d == :x
                    return [Cuboid(r_res, c1.y, c1.z)]
                elseif d == :y
                    return [Cuboid(c1.x, r_res, c1.z)]
                elseif d == :z
                    return [Cuboid(c1.x, c1.y, r_res)]
                end
            elseif getfield(c1, d).start >= getfield(c2, d).start && getfield(c1, d).stop > getfield(c2, d).stop
                r_res = max(getfield(c1, d).start, getfield(c2, d).stop):getfield(c1, d).stop
                if d == :x
                    return [Cuboid(r_res, c1.y, c1.z)]
                elseif d == :y
                    return [Cuboid(c1.x, r_res, c1.z)]
                elseif d == :z
                    return [Cuboid(c1.x, c1.y, r_res)]
                end
            elseif getfield(c1, d).start < getfield(c2, d).start && getfield(c1, d).stop > getfield(c2, d).stop
                r_res1 = getfield(c1, d).start:min(getfield(c1, d).stop, getfield(c2, d).start)
                r_res2 = max(getfield(c1, d).start, getfield(c2, d).stop):getfield(c1, d).stop
                if d == :x
                    return [Cuboid(r_res1, c1.y, c1.z), Cuboid(r_res2, c1.y, c1.z)]
                elseif d == :y
                    return [Cuboid(c1.x, r_res1, c1.z), Cuboid(c1.x, r_res2, c1.z)]
                elseif d == :z
                    return [Cuboid(c1.x, c1.y, r_res1), Cuboid(c1.x, c1.y, r_res2)]
                end
            end
        end
    # just make diff there instead of splitting parts of c2, here we split c1 based on c2, because esentially the diff is for c1 as it was for c2 in union
    else
        c_res = []
        x_low = c1.x.start:(c2.x.start-1)
        x_same = max(c2.x.start,c1.x.start):min(c2.x.stop,c1.x.stop)
        x_high = (c2.x.stop+1):c1.x.stop
        y_low = c1.y.start:(c2.y.start-1)
        y_same = max(c2.y.start,c1.y.start):min(c2.y.stop,c1.y.stop)
        y_high = (c2.y.stop+1):c1.y.stop
        z_low = c1.z.start:(c2.z.start-1)
        z_same = max(c2.z.start,c1.z.start):min(c2.z.stop,c1.z.stop)
        z_high = (c2.z.stop+1):c1.z.stop
        # all pairs, validate for them
        all_pairs = [(x,y,z) for (x,y,z)
            in reshape(product([x_low,x_same,x_high], [y_low,y_same,y_high], [z_low,z_same,z_high]) |> collect, :)
            if (x,y,z) != (x_same, y_same, z_same)]
        for (x_ran, y_ran, z_ran) in all_pairs
            if x_ran.start <= x_ran.stop && y_ran.start <= y_ran.stop && z_ran.start <= z_ran.stop
                push!(c_res, Cuboid(x_ran, y_ran, z_ran))
            end
        end
        return c_res
    end
end

function diff(cs::Vector{Cuboid}, c2::Cuboid)
    cs_res = Cuboid[]
    # c = cs[1]
    for c in cs
        if any_intersection(c, c2)
            # c1 = c
            append!(cs_res, diff(c, c2))
        else
            push!(cs_res, c)
        end
    end
    cs_res
end

count_points(c1::Cuboid) = prod(getfield(c1, i).stop - getfield(c1, i).start + 1 for i in [:x,:y,:z])
count_points(cs::Vector{Cuboid}) = mapreduce(count_points, +, cs)

using InteractiveUtils
@which maximum((4:8))
c1 = Cuboid(0:2,3:5,6:8)
c2 = Cuboid(3:4,3:5,6:8)
c3 = Cuboid(2:3,3:5,6:8)
c4 = Cuboid(0:2,8:10,6:8)
c5 = Cuboid(0:2,1:3,6:8)
c6 = Cuboid(0:2,1:4,6:8)
c7 = Cuboid(0:2,2:4,5:7)
c8 = Cuboid(1:2,3:5,6:8)
c9 = Cuboid(11:12, 13:13, 11:12)
c10 = Cuboid(13:13, 13:13, 11:12)
c11 = Cuboid(12:13, 13:13, 11:12)
c12 = Cuboid(11:13, 13:13, 11:12)

@assert do_union(c1,c1) == [c1]
@assert do_union(c1,c2) == [Cuboid(0:4,3:5,6:8)]
@assert do_union(c1,c3) == [Cuboid(0:3,3:5,6:8)]
@assert do_union(c1,c4) == [c1,c4]
@assert do_union(c1,c5) == [Cuboid(0:2,1:5,6:8)]
@assert do_union(c1,c6) == [Cuboid(0:2,1:5,6:8)]
@assert count_points(c1) == 3*3*3
@assert count_points(do_union(c1, c2)) == 3*3*3 + 2*3*3
@assert count_points(do_union(c1, c3)) == 4*3*3
@assert do_union(c1,c7) == [Cuboid(0:2,2:4,5:5), Cuboid(0:2,2:2,6:7), c1]
@assert count_points(do_union(c1, c6)) == 3*5*3
@assert count_points(do_union(c1, c7)) == 14*3
@assert do_union(c1,c8) == [c1]
@assert do_union(c9,c10) == [c12]
@assert do_union(c9,c11) == [c12]
@assert count_points(do_union(c9, c10)) == 6
@assert count_points(do_union(c9, c11)) == 6

# sum(are_neighboring(i,j) for (i,j) in combinations(on_boxes, 2))
function part1()
    data = process_data()
    valid_data = filter(x->all(-50 .<= x[2] .<= 50), data)
    first_box_on = findfirst(x->x[1] == "on", valid_data)
    _, box1 = popat!(valid_data, first_box_on)
    on_boxes = [Cuboid(box1[1]:box1[2],box1[3]:box1[4],box1[5]:box1[6])]
    # box_state, box_coords = valid_data[1]
    # box_state, box_coords = valid_data[3]
    @info "after modification" length(on_boxes) count_points(on_boxes)
    for (box_state, box_coords) in valid_data[1:6]
        new_box = Cuboid(box_coords[1]:box_coords[2],box_coords[3]:box_coords[4],box_coords[5]:box_coords[6])
        @info "adding to" length(on_boxes) box_state new_box
        if box_state == "on"
            on_boxes = do_union(on_boxes, new_box)
            # cs = on_boxes
            # c2 = new_box
        elseif box_state == "off"
            on_boxes = diff(on_boxes, new_box)
            diff(on_boxes, new_box)
        end
        @info "after modification" length(on_boxes) count_points(on_boxes)
    end

    
    on_boxes
    count_points(on_boxes)
end
# ┌ Info: after modification
# │   length(on_boxes) = 1
# └   count_points(on_boxes) = 139590
# ┌ Info: adding to
# │   length(on_boxes) = 1
# │   box_state = "on"
# └   new_box = Main.Day22.Cuboid(-20:33, -21:23, -26:28)
# ┌ Info: after modification
# │   length(on_boxes) = 4
# └   count_points(on_boxes) = 210918
# ┌ Info: adding to
# │   length(on_boxes) = 4
# │   box_state = "on"
# └   new_box = Main.Day22.Cuboid(-22:28, -29:23, -38:16)
# ┌ Info: after modification
# │   length(on_boxes) = 20
# └   count_points(on_boxes) = 671471
# ┌ Info: adding to
# │   length(on_boxes) = 20
# │   box_state = "on"
# └   new_box = Main.Day22.Cuboid(-46:7, -6:46, -50:-1)
# ┌ Info: after modification
# │   length(on_boxes) = 58
# └   count_points(on_boxes) = 1959623
# ┌ Info: adding to
# │   length(on_boxes) = 58
# │   box_state = "on"
# └   new_box = Main.Day22.Cuboid(-49:1, -3:46, -24:28)
# ┌ Info: after modification
# │   length(on_boxes) = 181
# └   count_points(on_boxes) = 6197831
# ┌ Info: adding to
# │   length(on_boxes) = 181
# │   box_state = "on"
# └   new_box = Main.Day22.Cuboid(2:47, -22:22, -23:27)
# ┌ Info: after modification
# │   length(on_boxes) = 339
# └   count_points(on_boxes) = 16406561
# ┌ Info: adding to
# │   length(on_boxes) = 339
# │   box_state = "on"
# └   new_box = Main.Day22.Cuboid(-27:23, -28:26, -21:29)
# ┌ Info: after modification
# │   length(on_boxes) = 1516
# └   count_points(on_boxes) = 51386671
# ┌ Info: adding to
# │   length(on_boxes) = 1516
# │   box_state = "on"
# └   new_box = Main.Day22.Cuboid(-39:5, -6:47, -3:44)
# ┌ Info: after modification
# │   length(on_boxes) = 6674
# └   count_points(on_boxes) = 191350741
# ┌ Info: adding to
# │   length(on_boxes) = 6674
# │   box_state = "on"
# └   new_box = Main.Day22.Cuboid(-30:21, -8:43, -13:34)
# ┌ Info: after modification
# │   length(on_boxes) = 33366
# └   count_points(on_boxes) = 918192285
# ┌ Info: adding to
# │   length(on_boxes) = 33366
# │   box_state = "on"
# └   new_box = Main.Day22.Cuboid(-22:26, -27:20, -29:19)
# ┌ Info: after modification
# │   length(on_boxes) = 111780
# └   count_points(on_boxes) = 2986010240
function part2()
    data = process_data()
end


end # module

if false
println(Day22.part1())
Day22.submit(Day22.part1(), Day22.cur_day, 1)
println(Day22.part2())
Day22.submit(Day22.part2(), Day22.cur_day, 2)
end
