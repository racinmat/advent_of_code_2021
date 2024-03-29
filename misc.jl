using DrWatson
quickactivate(@__DIR__)
using Pkg, Printf


# if Sys.iswindows()
# 	python_installation = read(`where python`, String) |> split |> x->x[1]
# 	ENV["PYTHON"] = python_installation
# 	Pkg.build("PyCall")
# elseif Sys.islinux()
# 	python_installation = read(`which python`, String) |> split |> x->x[1]
# 	ENV["PYTHON"] = python_installation
# 	Pkg.build("PyCall")
# end

using PyCall
pushfirst!(PyVector(pyimport("sys")."path"), joinpath(@__DIR__, "."))

function read_input(day::Int)
	misc = pyimport("misc")
	misc.read_day(day)
end

function submit(answer, day::Int, part::Int)
	misc = pyimport("misc")
	misc.submit_day(answer, day, part)
end

read_lines(data::AbstractString, delim='\n') = split(data, delim)
read_numbers(data::AbstractString, delim='\n', dtype=Int) = parse.(dtype, read_lines(data, delim))
read_number(data::AbstractString) = parse(Int, data)

function test_input(day::Int)
	data = open(joinpath(@sprintf("day_%02d", day), "test_input.txt")) do f
		read(f, String)
	end
	data
end

function read_file(day::Int, filename)
	data = open(joinpath(@sprintf("day_%02d", day), filename)) do f
		read(f, String)
	end
	data
end

read_file(filename::AbstractString) = day->read_file(day, filename)

replace_chars(str::AbstractString, repls::Pair...) = foldl(replace, collect(repls), init=str)
replace_chars(repls::Pair...) = x->replace_chars(x, repls...)

bits2num(arr::BitArray) = reduce((x,y)->x*2+y, arr)
bits2num(arr::Base.Iterators.Flatten) = reduce((x,y)->x*2+y, arr)
bits2num(arr::SubArray{T,U,BitVector}) where {T,U} = reduce((x,y)->x*2+y, arr)
bits2num(arr::Bool) = Int(arr)
