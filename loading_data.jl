# # Overview of data loading
# This is overview of code for loading data.
# Code snippets assume usage of functions from "misc.jl" and the input is in const raw_data
# For clarity there will always be only part of data.
using DrWatson
include(projectdir("misc.jl"))

# ## Types of input
# number per line
raw_data = """
173
179
200
210
226
229
220"""
process_data() = raw_data |> read_numbers
data = process_data()

# word and number per line
raw_data = """
forward 7
down 1
forward 9
forward 4
forward 7
down 8
forward 9
down 2
forward 5
down 3"""
function parse_row(str)
    vals = split(str)
    vals[1], parse(Int, vals[2])
end
process_data() = raw_data |> read_lines .|> parse_row
data = process_data()

# binary values, load it as BitMatrix
raw_data = """
111011110101
011000111010
100000010010
000111100110
110011111011
001100010111
011000100100
110011111010
101011010111"""
process_data() = raw_data |> read_lines .|> collect .|> (x->parse.(Bool, x)) |> x->hcat(x...)
data = process_data()

# List of comma delimited numbers and then matrices we want to load into 3D tensor
raw_data = """
31,50,68,16,25,15,28,80,41,8,75,45,96,9,3,98,83,27,62,42,59,99,95,13,55,10,23,84,18,76,87,56,88,66,1,58,92,89,19,54,85,74,39,93,77,26,30,52,69,48,91,73,72,38,64,53,32,51,6,29,17,90,34,61,70,4,7,57,44,97,82,37,43,14,81,65,11,22,5,36,71,35,78,12,0,94,47,49,33,79,63,86,40,21,24,46,20,2,67,60

95 91 54 75 45
46 94 39 44 85
31 43 24  2 70
90 58  4 30 77
13 26 38 52 34

68 14 99 63 46
67 16 82 10  8
55 52 41 51  4
90 17 32 44 74
89 94 73 56 36

 6 91  2 28 71
 7 88 37 21 36
95 32 84 57  8
13 79 89 75 48
47 81 66 17  5"""
using Pipe:@pipe
using Base.Iterators
parse_grid(x) = @pipe x .|> split .|> parse.(Int, _) |> _[2:end] |> reduce(hcat, _)
load_grids(x) = @pipe x |> (partition(_, 6) .|> parse_grid) |> reshape(reduce(hcat, _), (5, 5, :))
process_data() = @pipe raw_data |> read_lines |> (parse.(Int, split(_[1], ",")), load_grids(_[2:end]))
data = process_data()
# notes: reduce(hcat, _) and reduce(vcat, _) is very optimized. 
# Calling reduce(hcat, _) |> reshape(_, (5, 5, :)) is significantly faster than calling cat(_, dims=3)
# and still produces same result

# List of LineSegments, one per line, load it to line segment per matrix (2x2), so all input is vector of matrices(2x2)
raw_data = """
565,190 -> 756,381
402,695 -> 402,138
271,844 -> 98,844
276,41 -> 276,282
12,93 -> 512,593
322,257 -> 157,422
485,728 -> 685,528"""
parse_row(x) = split(x, " -> ") .|> (x->split(x, ",") .|> x->parse(Int32, x)) |> x->reduce(hcat, x)
is_axis_aligned(x::Matrix) = x[1,1] == x[1,2] || x[2,1] == x[2,2]
process_data() = raw_data |> read_lines .|> parse_row
data = process_data()

# One record per row, 2 numbers, character and string
raw_data = """
3-5 f: fgfff
6-20 n: qlzsnnnndwnlhwnxhvjn
6-7 j: jjjjjwrj
8-10 g: gggggggggg
5-6 t: ttttttft
6-11 h: khmchszhmzm"""
function parse_row(str)
    m = match(r"(\d+)-(\d+)\s(\w):\s(\w+)", str)
    parse(Int, m[1]), parse(Int, m[2]), first(m[3]), m[4]
end
process_data() = raw_data |> read_lines .|> parse_row
data = process_data()

# Loading two characters in grid to binary matrix
raw_data = """
...#....#.#...##......#.#...##.
.#..#...##..#....##........##..
..##.##...##.#.#....#..#......#
....#....#..#..#.#....#..###...
####.....##.#.##...##..#....#..
#........##...#..###..#.#.#.##.
.......###........##...#...#...
#.#...#..#..#...#...##.##......"""
process_data() = raw_data |> replace_chars("."=>"0", "#"=>"1") |>
    read_lines .|> collect .|> (x->parse.(Bool, x)) |> x->hcat(x...)
data = process_data()
# note that this transposes data, because most of time I don't need it in the same
# layout and transposing is sometimes waste of resources

# Groups of rows, separated by newline. 
# It does not matter if data in single group are separeated by space or newline.
# The output is list of dicts, with string before : as key, and string after : as value
raw_data = """
iyr:2015 cid:189 ecl:oth byr:1947 hcl:#6c4ab1 eyr:2026
hgt:174cm
pid:526744288

pid:688706448 iyr:2017 hgt:162cm cid:174 ecl:grn byr:1943 hcl:#808e9e eyr:2025

ecl:oth hcl:#733820 cid:124 pid:111220591
iyr:2019 eyr:2001
byr:1933 hgt:159in"""
str2dict(x) = Dict(x .|> y->split(y, ":"))
process_data() = raw_data |> x->read_lines(x, "\n\n") .|> x->split(x, (' ', '\n')) |> str2dict
data = process_data()

# Matrix of 4 letter, mapping 2 of them to 1 and 2 of them to 0
# Returning matrix of ints. But can be adjusted to matrix of bools to improve memory requirements.
raw_data = """
FFBBFFFLRL
FFBBFBBRRL
FBBBFFBLRL
BBFBFFBLRR
BFBBBFFLLL
BFBBBBBLLR
FBFBFBFLLR
BFBFBBFLLR"""
process_data() = raw_data |> replace_chars("F"=>"0", "B"=>"1", "L"=>"0", "R"=>"1") |> read_lines .|>
    collect .|> (x->parse.(Int, x)) |> x->hcat(x...)
data = process_data()

# Loading groups of lines to vector of vectors of strings
raw_data = """
zvxc
dv
vh
xv
jvem

mxfhdeyikljnz
vwzbjmsrgq

vbtjnh
vhejnbti
vthnjb
tsbhjnv"""
process_data() = raw_data |> x->read_lines(x, "\n\n") .|> x->split(x, "\n")
data = process_data()

# Parsing list of instructions/ingredients and their amount into Dict of Dicts, where first 2 words are key
# and the rest are in inner dict
raw_data = """
muted lavender bags contain 5 dull brown bags, 4 pale maroon bags, 2 drab orange bags.
plaid aqua bags contain 1 posh violet bag, 5 pale yellow bags, 4 bright salmon bags.
wavy lime bags contain 3 vibrant indigo bags, 1 posh gray bag.
pale coral bags contain 5 mirrored olive bags, 2 posh salmon bags.
faded chartreuse bags contain 1 plaid blue bag, 4 clear salmon bags, 5 muted teal bags."""
function parse_row(str)
    parts = split(str, ", ")
    start = popfirst!(parts)
    m = match(r"(\w+ \w+) bags contain (?:(?:(\d+) (\w+ \w+))|(no other)) bags?", start)
    bag_from = m[1]
    if m[4] == "no other"
        bags_to = Dict{String, Int}()
    else
        bags_to = Dict(String(m[3]) => parse(Int, m[2]))
        for part in parts
            m = match(r"(\d+) (\w+ \w+) bags?", part)
            bags_to[m[2]] = parse(Int, m[1])
        end
    end
    bag_from, bags_to
end
process_data() = raw_data .|> x->read_lines(x, "\n") .|> parse_row |> Dict
data = process_data()

# Parsing simple assembly-like instructions of word, value into vector of vectors of length 2, with parsed number
raw_data = """
acc -5
nop +333
acc +45
jmp +288
acc -9
jmp +1
acc +27
jmp +464
acc +34"""
function parse_row(str)
    m = match(r"(\w+) ((?:\+|-)?\d+)", str)
    [m[1], parse(Int, m[2])]
end
process_data() = raw_data |> read_lines .|> parse_row
data = process_data()

# Parsing letter and number per line into vector of tuple (enum, number)
raw_data = """
F12
W1
N3
E3
W3
F93
N2
R90
N4"""
abstract type Instruction end
abstract type Direction <: Instruction end
struct North <: Direction end
struct West <: Direction end
struct East <: Direction end
struct South <: Direction end
struct Forward <: Instruction end
struct RotateRight <: Instruction end
struct RotateLeft <: Instruction end
const translation = Dict(
    'N' => North(),
    'S' => South(),
    'E' => East(),
    'W' => West(),
    'F' => Forward(),
    'R' => RotateRight(),
    'L' => RotateLeft(),
)
parse_row(str) = @inbounds translation[str[1]], parse(Int, str[2:end])
process_data() = raw_data |> read_lines .|> parse_row
data = process_data()

# Parse number and list of numbers and placeholders into number and vector of (union, number)
raw_data = """
1002462
37,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,41,x,x"""
function parse_buses(x)
    tryparse.(Int, split(x[2], ","))
end
process_data() = raw_data |> read_lines |> x->(parse(Int, x[1]), parse_buses(x))
data = process_data()
