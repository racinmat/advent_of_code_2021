module Day13

using DrWatson
quickactivate(@__DIR__)
using OffsetArrays, SparseArrays
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
# const raw_data = cur_day |> read_file("input_test2.txt")
process_coords(row) = (row |> x->split(x,",") .|> x->parse(Int32,x)) |> x->CartesianIndex(x...)
function process_foldings(row)
    m = match(r"fold along (\w)=(\d+)", row)
    m[1], parse(Int32, m[2])
end
process_data() = raw_data |> x->split(x, "\n\n") .|> read_lines |> x -> (process_coords.(x[1]), process_foldings.(x[2]))

function a_fold1(coords, fold_axis, fold_coord)
    if fold_axis == "y"
        [c[2] > fold_coord ? CartesianIndex(c[1], 2*fold_coord - c[2]) : c for c in coords]
    elseif fold_axis == "x"
        [c[1] > fold_coord ? CartesianIndex(2*fold_coord - c[1], c[2]) : c for c in coords]
    end
end

function part1()
    coords, foldings = process_data()
    fold_axis, fold_coord = foldings[1]

    for (fold_axis, fold_coord) in foldings[1:1]
        coords = unique(a_fold1(coords, fold_axis, fold_coord))
    end
    length(coords)
end

function part2()
    coords, foldings = process_data()
    fold_axis, fold_coord = foldings[1]

    for (fold_axis, fold_coord) in foldings
        coords = unique(a_fold1(coords, fold_axis, fold_coord))
    end
    coords
    max_x = maximum(getindex.(coords, 1))
    max_y = maximum(getindex.(coords, 2))
    arr = OffsetArray(spzeros(Bool, max_x+1, max_y+1), 0:max_x,0:max_y)
    arr[coords] .= true
    @info "result" sparse(arr.parent')
end


end # module

if false
println(Day13.part1())
Day13.submit(Day13.part1(), Day13.cur_day, 1)
println(Day13.part2())
Day13.submit("LRFJBJEH", Day13.cur_day, 2)
end
