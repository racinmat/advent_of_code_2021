module Day15

using DrWatson
quickactivate(@__DIR__)
using Graphs, MetaGraphs
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
# const raw_data = cur_day |> read_file("input_test.txt")
# const raw_data = cur_day |> read_file("input_test2.txt")
# const raw_data = cur_day |> read_file("input_test3.txt")
process_data() = (raw_data |> read_lines .|> x->split(x, "") .|> x->parse.(Int8, x)) |> x->reduce(hcat, x)'

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
    the_way = a_star(g, LinearIndices(size(data))[1,1], LinearIndices(size(data))[size(data)...])
    sum(get_prop.(Ref(g), the_way, :weight))
end

function part2()
    data = process_data()
    # data = reshape([8],(1,1))
    # data_new = data .+ 1
    # data_new[data_new .> 9] .= 1
    new_data = repeat(data, 5, 5)
    i = 2
    j=1
    x,y = size(data)
    for i in 1:5
        for j in 1:5
            i == 1 && j == 1 && continue
            if j == 1
                prev_offset = (i-2)*x
                now_offset = (i-1)*x
                new_grid = @view new_data[(1+now_offset:x+now_offset),1:y]
                new_grid .= new_data[(1+prev_offset:x+prev_offset),1:y] .+ 1
                new_grid[new_grid .> 9] .= 1
            else
                prev_offset = (j-2)*y
                now_offset = (j-1)*y
                new_grid = @view new_data[1:x,(1+now_offset:y+now_offset)]
                new_grid .= new_data[1:x,(1+prev_offset:y+prev_offset)] .+ 1
                new_grid[new_grid .> 9] .= 1
            end
        end
    end
    g = build_graph(new_data)
    the_way = a_star(g, LinearIndices(size(new_data))[1,1], LinearIndices(size(new_data))[size(new_data)...])
    sum(get_prop.(Ref(g), the_way, :weight))
end


end # module

if false
println(Day15.part1())
Day15.submit(Day15.part1(), Day15.cur_day, 1)
println(Day15.part2())
Day15.submit(Day15.part2(), Day15.cur_day, 2)
end
