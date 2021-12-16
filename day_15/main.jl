module Day15

using DrWatson
quickactivate(@__DIR__)
using Graphs, MetaGraphs
using Pipe:@pipe
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
# const raw_data = cur_day |> read_file("input_test2.txt")
# const raw_data = cur_day |> read_file("input_test3.txt")
process_data() = @pipe (raw_data |> read_lines .|> split(_, "") .|> parse.(Int8, _)) |> reduce(hcat, _)

function build_graph(data)
    g1 = data |> size |> collect |> Graphs.SimpleGraphs.grid
    g2 = g1 |> edges |> SimpleDiGraphFromIterator
    for e in edges(g1)
        add_edge!(g2, e.dst, e.src)
    end
    g = g2 |> MetaDiGraph
    for (i, j) in enumerate(CartesianIndices(data))
        set_prop!(g, i, :coords, j)
    end
    e = collect(edges(g))[1]
    for e in edges(g)
        # transform vertex weight into edge weight by equation
        # new_edge_w(a,b) = edge_w(a,b) + node_w(b)
        # set_prop!(g, e, :weight, 0 + data[e.dst])
        # the graph must be directed!
        set_prop!(g, e, :weight, 0 + data[get_prop(g, e.dst, :coords)])
    end
    g
end

# this is basically shortest path search but with edge weights = 1 and vertex/node weight  of value in grid
function part1()
    data = process_data()
    g = build_graph(data)
    data_s = size(data)
    the_way = a_star(g, LinearIndices(data_s)[1,1], LinearIndices(data_s)[data_s...])
    sum(get_prop.(Ref(g), the_way, :weight))
end

function part2()
    data = process_data()
    new_data = repeat(data, 5, 5)
    x,y = size(data)
    for i in 1:5
        for j in 1:5
            i == 1 && j == 1 && continue
            prev_offset_x = (i-2)*x
            now_offset_x = (i-1)*x
            prev_offset_y = (j-2)*y
            now_offset_y = (j-1)*y
            if j == 1
                new_grid = @view new_data[1+now_offset_x:x+now_offset_x,1+now_offset_y:y+now_offset_y]
                new_grid .= new_data[1+prev_offset_x:x+prev_offset_x,1+now_offset_y:y+now_offset_y] .+ 1
                new_grid[new_grid .> 9] .= 1
            else
                new_grid = @view new_data[1+now_offset_x:x+now_offset_x,1+now_offset_y:y+now_offset_y]
                new_grid .= new_data[1+now_offset_x:x+now_offset_x,1+prev_offset_y:y+prev_offset_y] .+ 1
                new_grid[new_grid .> 9] .= 1
            end
        end
    end
    g = build_graph(new_data)
    data_s = size(new_data)
    the_way = a_star(g, LinearIndices(data_s)[1,1], LinearIndices(data_s)[data_s...])
    sum(get_prop.(Ref(g), the_way, :weight))
end


end # module

if false
println(Day15.part1())
Day15.submit(Day15.part1(), Day15.cur_day, 1)
println(Day15.part2())
Day15.submit(Day15.part2(), Day15.cur_day, 2)
end
