```@meta
EditURL = "<unknown>/loading_data.jl"
```

# Overview of data loading
This is overview of code for loading data.
Code snippets assume usage of functions from "misc.jl" and the input is in const raw_data
For clarity there will always be only part of data.

````julia
using DrWatson
include(projectdir("misc.jl"))
````

````
bits2num (generic function with 1 method)
````

Data will be structured to some arbitrary categories or types

## Simple row
### Number per line
parse number per line to vector of ints

````julia
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
````

````
7-element Vector{Int64}:
 173
 179
 200
 210
 226
 229
 220
````

### Word and number per line

````julia
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
````

````
10-element Vector{Tuple{SubString{String}, Int64}}:
 ("forward", 7)
 ("down", 1)
 ("forward", 9)
 ("forward", 4)
 ("forward", 7)
 ("down", 8)
 ("forward", 9)
 ("down", 2)
 ("forward", 5)
 ("down", 3)
````

### List of structures, one per line
List of LineSegments, one per line, load it to line segment per matrix (2x2), so all input is vector of matrices(2x2)

````julia
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
````

````
7-element Vector{Matrix{Int32}}:
 [565 756; 190 381]
 [402 402; 695 138]
 [271 98; 844 844]
 [276 276; 41 282]
 [12 512; 93 593]
 [322 157; 257 422]
 [485 685; 728 528]
````

One record per row, 2 numbers, character and string

````julia
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
````

````
6-element Vector{Tuple{Int64, Int64, Char, SubString{String}}}:
 (3, 5, 'f', "fgfff")
 (6, 20, 'n', "qlzsnnnndwnlhwnxhvjn")
 (6, 7, 'j', "jjjjjwrj")
 (8, 10, 'g', "gggggggggg")
 (5, 6, 't', "ttttttft")
 (6, 11, 'h', "khmchszhmzm")
````

Parsing list of instructions/ingredients and their amount into Dict of Dicts, where first 2 words are key
and the rest are in inner dict

````julia
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
````

````
Dict{SubString{String}, Dict{String, Int64}} with 5 entries:
  "wavy lime" => Dict("vibrant indigo"=>3, "posh gray"=>1)
  "pale coral" => Dict("mirrored olive"=>5, "posh salmon"=>2)
  "faded chartreuse" => Dict("clear salmon"=>4, "muted teal"=>5, "plaid blue"=>1)
  "muted lavender" => Dict("drab orange"=>2, "dull brown"=>5, "pale maroon"=>4)
  "plaid aqua" => Dict("bright salmon"=>4, "pale yellow"=>5, "posh violet"=>1)
````

Parsing simple assembly-like instructions of word, value into vector of vectors of length 2, with parsed number

````julia
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
````

````
9-element Vector{Vector{Any}}:
 ["acc", -5]
 ["nop", 333]
 ["acc", 45]
 ["jmp", 288]
 ["acc", -9]
 ["jmp", 1]
 ["acc", 27]
 ["jmp", 464]
 ["acc", 34]
````

Parsing letter and number per line into vector of tuple (enum, number)

````julia
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
````

````
9-element Vector{Tuple{Main.##301.Instruction, Int64}}:
 (Main.##301.Forward(), 12)
 (Main.##301.West(), 1)
 (Main.##301.North(), 3)
 (Main.##301.East(), 3)
 (Main.##301.West(), 3)
 (Main.##301.Forward(), 93)
 (Main.##301.North(), 2)
 (Main.##301.RotateRight(), 90)
 (Main.##301.North(), 4)
````

## Matrix-like data
### Binary Matrix
binary values, load it as BitMatrix

````julia
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
process_data() = raw_data |> read_lines .|> collect .|> (x->parse.(Bool, x)) |> x->reduce(hcat, x)
data = process_data()
````

````
12×9 BitMatrix:
 1  0  1  0  1  0  0  1  1
 1  1  0  0  1  0  1  1  0
 1  1  0  0  0  1  1  0  1
 0  0  0  1  0  1  0  0  0
 1  0  0  1  1  0  0  1  1
 1  0  0  1  1  0  0  1  1
 1  1  0  1  1  0  1  1  0
 1  1  1  0  1  1  0  1  1
 0  1  0  0  1  0  0  1  0
 1  0  0  1  0  1  1  0  1
 0  1  1  1  1  1  0  1  1
 1  0  0  0  1  1  0  0  1
````

Loading two characters in grid to binary matrix

````julia
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
    read_lines .|> collect .|> (x->parse.(Bool, x)) |> x->reduce(hcat, x)
data = process_data()
````

````
31×8 BitMatrix:
 0  0  0  0  1  1  0  1
 0  1  0  0  1  0  0  0
 0  0  1  0  1  0  0  1
 1  0  1  0  1  0  0  0
 0  1  0  1  0  0  0  0
 0  0  1  0  0  0  0  0
 0  0  1  0  0  0  0  1
 0  0  0  0  0  0  1  0
 1  1  0  0  0  0  1  0
 0  1  0  1  1  1  1  1
 1  0  1  0  1  1  0  0
 0  0  1  0  0  0  0  0
 0  1  0  1  1  0  0  1
 0  0  1  0  0  0  0  0
 1  0  0  0  1  1  0  0
 1  0  1  1  1  0  0  0
 0  0  0  0  0  0  0  1
 0  1  0  1  0  1  0  0
 0  1  0  0  0  1  1  0
 0  0  0  0  1  1  1  0
 0  0  1  0  1  0  0  1
 0  0  0  0  0  0  0  1
 1  0  0  1  0  1  0  0
 0  0  1  0  1  0  1  1
 1  0  0  0  0  1  0  1
 0  0  0  1  0  0  0  0
 0  0  0  1  0  1  0  0
 0  1  0  1  0  0  1  0
 1  1  0  0  1  1  0  0
 1  0  0  0  0  1  0  0
 0  0  1  0  0  0  0  0
````

note that this transposes data, because most of time I don't need it in the same
layout and transposing is sometimes waste of resources

Matrix of 4 letter, mapping 2 of them to 1 and 2 of them to 0
Returning matrix of ints. But can be adjusted to matrix of bools to improve memory requirements.

````julia
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
    collect .|> (x->parse.(Int, x)) |> x->reduce(hcat, x)
data = process_data()
````

````
10×8 Matrix{Int64}:
 0  0  0  1  1  1  0  1
 0  0  1  1  0  0  1  0
 1  1  1  0  1  1  0  1
 1  1  1  1  1  1  1  0
 0  0  0  0  1  1  0  1
 0  1  0  0  0  1  1  1
 0  1  1  1  0  1  0  0
 0  1  0  0  0  0  0  0
 1  1  1  1  0  0  0  0
 0  0  0  1  0  1  1  1
````

List of comma delimited numbers and then matrices we want to load into 3D tensor

````julia
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
````

````
([31, 50, 68, 16, 25, 15, 28, 80, 41, 8, 75, 45, 96, 9, 3, 98, 83, 27, 62, 42, 59, 99, 95, 13, 55, 10, 23, 84, 18, 76, 87, 56, 88, 66, 1, 58, 92, 89, 19, 54, 85, 74, 39, 93, 77, 26, 30, 52, 69, 48, 91, 73, 72, 38, 64, 53, 32, 51, 6, 29, 17, 90, 34, 61, 70, 4, 7, 57, 44, 97, 82, 37, 43, 14, 81, 65, 11, 22, 5, 36, 71, 35, 78, 12, 0, 94, 47, 49, 33, 79, 63, 86, 40, 21, 24, 46, 20, 2, 67, 60], [95 46 31 90 13; 91 94 43 58 26; 54 39 24 4 38; 75 44 2 30 52; 45 85 70 77 34;;; 68 67 55 90 89; 14 16 52 17 94; 99 82 41 32 73; 63 10 51 44 56; 46 8 4 74 36;;; 6 7 95 13 47; 91 88 32 79 81; 2 37 84 89 66; 28 21 57 75 17; 71 36 8 48 5])
````

notes: `reduce(hcat, \_)` and `reduce(vcat, \_)` is very optimized.
Calling reduce(hcat, _) |> reshape(_, (5, 5, :)) is significantly faster than calling cat(_, dims=3)
and still produces same result

Groups of rows, separated by newline.
It does not matter if data in single group are separeated by space or newline.
The output is list of dicts, with string before : as key, and string after : as value

````julia
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
````

````
3-element Vector{Dict{SubString{String}, SubString{String}}}:
 Dict("hcl" => "#6c4ab1", "ecl" => "oth", "cid" => "189", "hgt" => "174cm", "iyr" => "2015", "eyr" => "2026", "pid" => "526744288", "byr" => "1947")
 Dict("hcl" => "#808e9e", "ecl" => "grn", "pid" => "688706448", "hgt" => "162cm", "iyr" => "2017", "cid" => "174", "eyr" => "2025", "byr" => "1943")
 Dict("hcl" => "#733820", "ecl" => "oth", "cid" => "124", "pid" => "111220591", "iyr" => "2019", "eyr" => "2001", "hgt" => "159in", "byr" => "1933")
````

Loading groups of lines to vector of vectors of strings

````julia
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
````

````
3-element Vector{Vector{SubString{String}}}:
 ["zvxc", "dv", "vh", "xv", "jvem"]
 ["mxfhdeyikljnz", "vwzbjmsrgq"]
 ["vbtjnh", "vhejnbti", "vthnjb", "tsbhjnv"]
````

Parse number and list of numbers and placeholders into number and vector of (union, number)

````julia
raw_data = """
1002462
37,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,41,x,x"""
function parse_buses(x)
    tryparse.(Int, split(x[2], ","))
end
process_data() = raw_data |> read_lines |> x->(parse(Int, x[1]), parse_buses(x))
data = process_data()
````

````
(1002462, Union{Nothing, Int64}[37, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, 41, nothing, nothing])
````

Parse word and array of bits and missing and some array values into vector,
where mask has second element of vector, mem has ints as 2nd and 3rd value

````julia
raw_data = """
mask = 100110X100000XX0X100X1100110X001X100
mem[21836] = 68949
mem[61020] = 7017251
mask = X00X0011X11000X1010X0X0X110X0X011000
mem[30885] = 231192
mem[26930] = 133991367
mem[1005] = 121034
mem[20714] = 19917
mem[55537] = 9402614
mask = XXXX001111100011X1110000XX001011100X
mem[60166] = 183248310
mem[2049] = 5589249"""
const mapping = Dict('0'=>false, '1'=>true, 'X'=>missing)

function parse_row(x)
    if startswith(x, "mask ")
        m = match(r"mask = ((?:\d|X)+)", x)
        return "mask", getindex.(Ref(mapping), collect(m[1]))
    else
        m = match(r"mem\[(\d+)\] = (\d+)", x)
        return "mem", (parse(Int, m[1]), parse(Int, m[2]))
    end
    tryparse.(Int, split(x[2], ","))
end
process_data() = raw_data |> read_lines .|> parse_row
data = process_data()
````

````
12-element Vector{Tuple{String, Any}}:
 ("mask", Union{Missing, Bool}[true, false, false, true, true, false, missing, true, false, false, false, false, false, missing, missing, false, missing, true, false, false, missing, true, true, false, false, true, true, false, missing, false, false, true, missing, true, false, false])
 ("mem", (21836, 68949))
 ("mem", (61020, 7017251))
 ("mask", Union{Missing, Bool}[missing, false, false, missing, false, false, true, true, missing, true, true, false, false, false, missing, true, false, true, false, missing, false, missing, false, missing, true, true, false, missing, false, missing, false, true, true, false, false, false])
 ("mem", (30885, 231192))
 ("mem", (26930, 133991367))
 ("mem", (1005, 121034))
 ("mem", (20714, 19917))
 ("mem", (55537, 9402614))
 ("mask", Union{Missing, Bool}[missing, missing, missing, missing, false, false, true, true, true, true, true, false, false, false, true, true, missing, true, true, true, false, false, false, false, missing, missing, false, false, true, false, true, true, true, false, false, missing])
 ("mem", (60166, 183248310))
 ("mem", (2049, 5589249))
````

Parse comma separated values

````julia
raw_data = """
0,13,16,17,1,10,6"""
process_data() = raw_data |> x->read_numbers(x, ",")
data = process_data()
````

````
7-element Vector{Int64}:
  0
 13
 16
 17
  1
 10
  6
````

Parse 3 types of input
first part to vector of tuple(string, interval, interval)
vector of ints
vector of vectors of ints

````julia
raw_data = """
departure location: 45-535 or 550-961
departure platform: 46-121 or 138-965
arrival platform: 46-823 or 834-971
arrival track: 30-464 or 486-963
type: 33-205 or 218-965
wagon: 43-101 or 118-951

your ticket:
173,191,61,199,101,179,257

nearby tickets:
949,764,551,379,767,144,556
438,627,99,622,408,671,695
879,876,665,928,874,436,766"""
using Intervals
function parse_departure(str)
    m = match(r"([\w ]+): (\d+)-(\d+) or (\d+)-(\d+)", str)
    ints = parse.(Int, [m[2], m[3], m[4], m[5]])
    m[1], Interval{Closed, Closed}(ints[1:2]...), Interval{Closed, Closed}(ints[3:4]...)
end

function parse_input(departures, my_ticket, other_tickets)
    conditions = departures |> read_lines .|> parse_departure
    my_ticket_nums = read_lines(my_ticket)[2] |> x->read_numbers(x, ",")
    other_tickets_nums = read_lines(other_tickets)[2:end] .|> x->read_numbers(x, ",")
    conditions, my_ticket_nums, other_tickets_nums
end
process_data() = raw_data |> x->split(x, "\n\n") |> x->parse_input(x...)
data = process_data()
conditions, my_ticket_nums, other_tickets_nums = data
conditions

my_ticket_nums

other_tickets_nums
````

````
3-element Vector{Vector{Int64}}:
 [949, 764, 551, 379, 767, 144, 556]
 [438, 627, 99, 622, 408, 671, 695]
 [879, 876, 665, 928, 874, 436, 766]
````

Parsing data into dict with values pair of vectors of ints or vector of ints and strings into string per line

````julia
raw_data = """
102: 100 47 | 76 84
23: 60 47 | 73 84
132: 17 47 | 81 84
108: 55 100
18: 116 47 | 26 84

babaaabbbababababbbbabbaabbaabaa
babaaaabaaaaababbbbaaaaa
abbabaabbaaabababaabbbbabbbbbaabbbbabababaaaabbbbababbbb"""
function parse_rule(str)
    if '"' in str
        m = match(r"(\d+): \"(\w)\"", str)
        parse(Int, m[1]) => m[2]
    elseif '|' in str
        m = match(r"(\d+):((?: (?:\d+))+) \|((?: (?:\d+))+)", str)
        parse(Int, m[1]) => (parse.(Int, split(m[2])), parse.(Int, split(m[3])))
    else
        m = match(r"(\d+):((?: (?:\d+))+)", str)
        parse(Int, m[1]) => parse.(Int, split(m[2]))
    end
end

parse_input(rules, texts) = Dict(parse_rule.(rules)), texts
process_data() = raw_data |> x->split(x, "\n\n") .|> (x->split(x, "\n")) |> x->parse_input(x...)

rules, texts = process_data()
rules

texts
````

````
3-element Vector{SubString{String}}:
 "babaaabbbababababbbbabbaabbaabaa"
 "babaaaabaaaaababbbbaaaaa"
 "abbabaabbaaabababaabbbbabbbbbaabbbbabababaaaabbbbababbbb"
````

Parse list of grinds into dict of binary matrices

````julia
raw_data = """
Tile 3593:
#..#.##...
.#..#.#...
.#####..#.
.......#.#
#...#.....
..#.....##
.#....#...
.#..#.....
..#......#
#.####.##.

Tile 3041:
####.#.###
#..#..#.#.
.......#.#
#.....#...
....#....#
.#.......#
#..#.....#
#...#.....
##........
##.##...##

Tile 3761:
...#..##.#
#....#..#.
........#.
#..##.....
#..#.....#
.#....#..#
#.#....#..
#....#....
.....#...#
#.#####..#"""
function read_tile(str)
    lines = read_lines(str)
    tile_desc = first(lines)
    m = match(r"Tile (\d+):", tile_desc)
    grid = lines[2:end] .|> replace_chars("."=>"0", "#"=>"1") .|> collect .|> (x->parse.(Bool, x)) |> x->reduce(hcat, x)'
    parse(Int, m[1]) => grid
end
process_data() = raw_data |> x->split(x, "\n\n") .|> read_tile |> Dict
data = process_data()
````

````
Dict{Int64, LinearAlgebra.Adjoint{Bool, BitMatrix}} with 3 entries:
  3593 => [1 0 0 1 0 1 1 0 0 0; 0 1 0 0 1 0 1 0 0 0; 0 1 1 1 1 1 0 0 1 0; 0 0 0 0 0 0 0 1 0 1; 1 0 0 0 1 0 0 0 0 0; 0 0 1 0 0 0 0 0 1 1; 0 1 0 0 0 0 1 0 0 0; 0 1 0 0 1 0 0 0 0 0; 0 0 1 0 0 0 0 0 0 1; 1 0 1 1 1 1 0 1 1 0]
  3761 => [0 0 0 1 0 0 1 1 0 1; 1 0 0 0 0 1 0 0 1 0; 0 0 0 0 0 0 0 0 1 0; 1 0 0 1 1 0 0 0 0 0; 1 0 0 1 0 0 0 0 0 1; 0 1 0 0 0 0 1 0 0 1; 1 0 1 0 0 0 0 1 0 0; 1 0 0 0 0 1 0 0 0 0; 0 0 0 0 0 1 0 0 0 1; 1 0 1 1 1 1 1 0 0 1]
  3041 => [1 1 1 1 0 1 0 1 1 1; 1 0 0 1 0 0 1 0 1 0; 0 0 0 0 0 0 0 1 0 1; 1 0 0 0 0 0 1 0 0 0; 0 0 0 0 1 0 0 0 0 1; 0 1 0 0 0 0 0 0 0 1; 1 0 0 1 0 0 0 0 0 1; 1 0 0 0 1 0 0 0 0 0; 1 1 0 0 0 0 0 0 0 0; 1 1 0 1 1 0 0 0 1 1]
````

Parsing input into vector of tuple of 2 vectors, one of things before (), one of them after ()

````julia
raw_data = """
brlcg gxgx cqrgc ccdxx lkndzp lnpvrj ljlxklz zbxg (contains sesame, eggs)
mxphhh kvrt dxffd brdd vgnj ttzqv qbxntsph jvsljv (contains soy)
frxm vgnpc qfmm tzjrx kbqh vqcmr jvsljv brdd tpd kvkkq (contains shellfish)
ptm jvxn sbt gqpfc hzvzp gbknxh slkfgq vtjtkgnq dpvc (contains wheat)
nbkbm hvbj zvsrp dczmjg dmfgb brdd xcrldj slkfgq qbpgp (contains sesame, shellfish, eggs)
bldzjjb mncbm zpdkh vzjq kddclv cxbz qhxqsc slkfgq mlrqp (contains sesame, shellfish)"""
function parse_row(str)
    m = match(r"([\w ]+)\(contains ([\w, ]+)\)", str)
    split(m[1]), split(m[2], ", ")
end
process_data() = raw_data |> read_lines .|> parse_row
data = process_data()
````

````
6-element Vector{Tuple{Vector{SubString{String}}, Vector{SubString{String}}}}:
 (["brlcg", "gxgx", "cqrgc", "ccdxx", "lkndzp", "lnpvrj", "ljlxklz", "zbxg"], ["sesame", "eggs"])
 (["mxphhh", "kvrt", "dxffd", "brdd", "vgnj", "ttzqv", "qbxntsph", "jvsljv"], ["soy"])
 (["frxm", "vgnpc", "qfmm", "tzjrx", "kbqh", "vqcmr", "jvsljv", "brdd", "tpd", "kvkkq"], ["shellfish"])
 (["ptm", "jvxn", "sbt", "gqpfc", "hzvzp", "gbknxh", "slkfgq", "vtjtkgnq", "dpvc"], ["wheat"])
 (["nbkbm", "hvbj", "zvsrp", "dczmjg", "dmfgb", "brdd", "xcrldj", "slkfgq", "qbpgp"], ["sesame", "shellfish", "eggs"])
 (["bldzjjb", "mncbm", "zpdkh", "vzjq", "kddclv", "cxbz", "qhxqsc", "slkfgq", "mlrqp"], ["sesame", "shellfish"])
````

Load data into vector of tuples(string, vector of ints)

````julia
raw_data = """
Player 1:
12
48
26
22
44
16
31

Player 2:
14
45
4
24
1
7
36"""
function parse_player(str)
    lines = read_lines(str)
    lines[1][begin:end-1], parse.(Int, lines[2:end])
end
process_data() = raw_data |> x->split(x, "\n\n") .|> parse_player
player1, player2 = process_data()
player1

player2
````

````
("Player 2", [14, 45, 4, 24, 1, 7, 36])
````

Load strings into vector of vectors of directions

````julia
raw_data = """
seseseseseswsesesenwseseseswenweeese
nwneneseswneneweeneneeeeneeneene
swswseswswswswswseseeswswswswseswsesww
nwsenwnenenwnwnwewnwnwnwnwnwnwwnwnwnw
sesewseesesenwnewewwnewseeseseswsene
eneneneeewswnenewsenenwnwnenewnene"""
parse_row(str) = SubString.(str, findall(r"(?:se)|(?:sw)|(?:ne)|(?:nw)|e|w", str))
process_data() = raw_data |> read_lines .|> parse_row
data = process_data()
````

````
6-element Vector{Vector{SubString{String}}}:
 ["se", "se", "se", "se", "se", "sw", "se", "se", "se", "nw", "se", "se", "se", "sw", "e", "nw", "e", "e", "e", "se"]
 ["nw", "ne", "ne", "se", "sw", "ne", "ne", "w", "e", "e", "ne", "ne", "e", "e", "e", "ne", "e", "ne", "e", "ne"]
 ["sw", "sw", "se", "sw", "sw", "sw", "sw", "sw", "se", "se", "e", "sw", "sw", "sw", "sw", "se", "sw", "se", "sw", "w"]
 ["nw", "se", "nw", "ne", "ne", "nw", "nw", "nw", "e", "w", "nw", "nw", "nw", "nw", "nw", "nw", "w", "nw", "nw", "nw"]
 ["se", "se", "w", "se", "e", "se", "se", "nw", "ne", "w", "e", "w", "w", "ne", "w", "se", "e", "se", "se", "sw", "se", "ne"]
 ["e", "ne", "ne", "ne", "e", "e", "w", "sw", "ne", "ne", "w", "se", "ne", "nw", "nw", "ne", "ne", "w", "ne", "ne"]
````

Parse 2 lines of comma separated values of letter and number

````julia
raw_data = """
R995,U982,R941,U681,L40,D390,R223,U84,L549,U568,R693
L996,D167,R633,D49,L319,D985,L504,U273,L330,U904,R741"""
process_data() = raw_data |> read_lines .|> x->split(x, ',') .|> x->(x[1], parse(Int, x[2:end]))
line1, line2 = process_data()
line1

line2
````

````
11-element Vector{Tuple{Char, Int64}}:
 ('L', 996)
 ('D', 167)
 ('R', 633)
 ('D', 49)
 ('L', 319)
 ('D', 985)
 ('L', 504)
 ('U', 273)
 ('L', 330)
 ('U', 904)
 ('R', 741)
````

Load list of ) delimited numbers

````julia
raw_data = """
YMK)12Q
N3N)11S
P73)8Q3
PC8)14H
CDH)SR2"""
process_data() = raw_data |> x->split(x, '\n') .|> x->split(x, ')')
data = process_data()
````

````
5-element Vector{Vector{SubString{String}}}:
 ["YMK", "12Q"]
 ["N3N", "11S"]
 ["P73", "8Q3"]
 ["PC8", "14H"]
 ["CDH", "SR2"]
````

Load one long string of ints into 3D tensor

````julia
raw_data = """
21120212122222222222122221222220202222222222212222122022222222222222222222220222222222222212212102222221222222"""
process_data() = raw_data |> collect |> x->parse.(Int, x) |> x->reshape(x, (5, 11, :))
data = process_data()
````

````
5×11×2 Array{Int64, 3}:
[:, :, 1] =
 2  2  2  2  1  1  2  2  2  1  1
 1  1  2  2  2  2  0  2  2  2  2
 1  2  2  2  2  2  2  2  2  2  2
 2  1  2  2  2  2  0  2  2  2  0
 0  2  2  2  2  2  2  2  2  2  2

[:, :, 2] =
 2  2  2  2  2  2  2  1  1  2  2
 2  2  2  2  0  2  2  2  0  2  2
 2  2  2  2  2  2  2  2  2  2  2
 2  2  2  2  2  2  2  1  2  1  2
 2  2  2  2  2  2  2  2  2  2  2
````

Load list of coordinates into matrix

````julia
raw_data = """
<x=-10, y=-13, z=7>
<x=1, y=2, z=1>
<x=-15, y=-3, z=13>
<x=3, y=7, z=-4>"""
function parse_row(str)
    m = match(r"<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>", str)
    Vector(parse.(Int32, [m[1], m[2], m[3]]))
end
process_data() = raw_data |> read_lines .|> parse_row |> x->reduce(hcat, x)'
data = process_data()
````

````
4×3 adjoint(::Matrix{Int32}) with eltype Int32:
 -10  -13   7
   1    2   1
 -15   -3  13
   3    7  -4
````

Load into list of tuple of vector of pairs and pair

````julia
raw_data = """
1 RNQHX, 1 LFKRJ, 1 JNGM => 8 DSRGV
2 HCQGN, 1 XLNC, 4 WRPWG => 7 ZGVZL
172 ORE => 5 WRPWG
7 MXMQ, 1 SLTF => 3 JTBLB"""
matchall(r::Regex,s::AbstractString; overlap::Bool=false) = collect((m.match for m=eachmatch(r, s, overlap=overlap)))
function parse_row(str)
    m = matchall(r"(\d+ [A-Z]+)", str)
    res = [match(r"(\d+) ([A-Z]+)", i).captures for i in m]
    res = res .|> x->(parse(Int, x[1]), x[2])
    res[1:end-1], res[end]
end
process_data() = raw_data |> read_lines .|> parse_row
data = process_data()
````

````
4-element Vector{Tuple{Vector{Tuple{Int64, SubString{String}}}, Tuple{Int64, SubString{String}}}}:
 ([(1, "RNQHX"), (1, "LFKRJ"), (1, "JNGM")], (8, "DSRGV"))
 ([(2, "HCQGN"), (1, "XLNC"), (4, "WRPWG")], (7, "ZGVZL"))
 ([(172, "ORE")], (5, "WRPWG"))
 ([(7, "MXMQ"), (1, "SLTF")], (3, "JTBLB"))
````

Load map into graph prepared for graph searching algoritms

````julia
raw_data = """
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################"""
using Graphs, MetaGraphs
import MetaGraphs: MetaGraph
function build_graph(data)
    g = Graphs.SimpleGraphs.grid(data |> size |> collect)
    g = MetaGraph(g)
    start_node = 0
    key2node = Dict{Char, Int}()
    door2node = Dict{Char, Int}()
    door2neighbors = Dict{Char, Vector{Int}}()
    for (i, j) in enumerate(CartesianIndices(data))
        set_prop!(g, i, :coords, j)
    end

    for vertex in nv(g):-1:1
        coords = get_prop(g, vertex, :coords)
        data[coords] == '#' && rem_vertex!(g, vertex)
    end

    for vertex in vertices(g)
        coords = get_prop(g, vertex, :coords)
        if data[coords] == '@'
            start_node = vertex
        elseif Int('a') <= Int(data[coords]) <= Int('z')
            key2node[data[coords]] = vertex
        elseif Int('A') <= Int(data[coords]) <= Int('Z')
            door2node[data[coords]] = vertex
        end
    end
    full_graph = copy(g.graph)
    for (letter, node) in door2node
        neighbors_list = neighbors(g, node) |> collect
        door2neighbors[letter] = neighbors_list
        for n in neighbors_list
            rem_edge!(g, node, n)
        end
    end

    g.graph, key2node, door2node, door2neighbors, start_node, g.vprops, full_graph
end

process_data() = raw_data |> read_lines .|> collect |>
    x->reduce(hcat, x) |> x->permutedims(x, [2, 1]) |> build_graph
data = process_data()
````

````
({45, 34} undirected simple Int64 graph, Dict('f' => 7, 'd' => 9, 'a' => 31, 'c' => 35, 'e' => 37, 'b' => 16), Dict('B' => 21, 'D' => 17, 'A' => 33, 'E' => 27, 'C' => 2), Dict('C' => [8, 42], 'D' => [12, 22], 'A' => [25, 41], 'E' => [22, 32], 'B' => [1, 43]), 5, Dict{Int64, Dict{Symbol, Any}}(5 => Dict(:coords => CartesianIndex(2, 16)), 35 => Dict(:coords => CartesianIndex(2, 22)), 30 => Dict(:coords => CartesianIndex(4, 20)), 32 => Dict(:coords => CartesianIndex(2, 7)), 6 => Dict(:coords => CartesianIndex(4, 19)), 45 => Dict(:coords => CartesianIndex(4, 15)), 4 => Dict(:coords => CartesianIndex(4, 10)), 13 => Dict(:coords => CartesianIndex(4, 21)), 12 => Dict(:coords => CartesianIndex(2, 3)), 28 => Dict(:coords => CartesianIndex(4, 13)), 23 => Dict(:coords => CartesianIndex(4, 17)), 41 => Dict(:coords => CartesianIndex(2, 15)), 43 => Dict(:coords => CartesianIndex(2, 21)), 11 => Dict(:coords => CartesianIndex(4, 11)), 36 => Dict(:coords => CartesianIndex(4, 14)), 39 => Dict(:coords => CartesianIndex(4, 8)), 7 => Dict(:coords => CartesianIndex(2, 2)), 25 => Dict(:coords => CartesianIndex(2, 13)), 34 => Dict(:coords => CartesianIndex(4, 7)), 2 => Dict(:coords => CartesianIndex(2, 10)), 10 => Dict(:coords => CartesianIndex(4, 16)), 18 => Dict(:coords => CartesianIndex(2, 17)), 26 => Dict(:coords => CartesianIndex(4, 23)), 27 => Dict(:coords => CartesianIndex(2, 6)), 42 => Dict(:coords => CartesianIndex(2, 9)), 16 => Dict(:coords => CartesianIndex(2, 12)), 20 => Dict(:coords => CartesianIndex(4, 12)), 19 => Dict(:coords => CartesianIndex(4, 4)), 44 => Dict(:coords => CartesianIndex(4, 9)), 9 => Dict(:coords => CartesianIndex(4, 2)), 31 => Dict(:coords => CartesianIndex(2, 18)), 29 => Dict(:coords => CartesianIndex(4, 6)), 21 => Dict(:coords => CartesianIndex(2, 20)), 38 => Dict(:coords => CartesianIndex(4, 18)), 24 => Dict(:coords => CartesianIndex(4, 5)), 8 => Dict(:coords => CartesianIndex(2, 11)), 17 => Dict(:coords => CartesianIndex(2, 4)), 37 => Dict(:coords => CartesianIndex(2, 8)), 1 => Dict(:coords => CartesianIndex(2, 19)), 22 => Dict(:coords => CartesianIndex(2, 5)), 14 => Dict(:coords => CartesianIndex(4, 3)), 3 => Dict(:coords => CartesianIndex(4, 22)), 33 => Dict(:coords => CartesianIndex(2, 14)), 40 => Dict(:coords => CartesianIndex(2, 23)), 15 => Dict(:coords => CartesianIndex(3, 23))), {45, 44} undirected simple Int64 graph)
````

Parse rows of different types into vector of custom structures

````julia
raw_data = """
cut 181
deal with increment 61
cut -898
deal with increment 19
cut -1145
deal with increment 35
cut 3713"""
abstract type Instruction end
struct CutInstruction <: Instruction
    i::Signed
end
struct DealNewInstruction <: Instruction end
struct DealIncrementInstruction <: Instruction
    i::Signed
end
function parse_instruction(row)
    if match(r"cut -?\d+", row) != nothing
        return CutInstruction(parse(Int128, match(r"cut (-?\d+)", row)[1]))
    elseif match(r"deal into new stack", row) != nothing
        return DealNewInstruction()
    elseif match(r"deal with increment \d+", row) != nothing
        return DealIncrementInstruction(parse(Int128, match(r"deal with increment (\d+)", row)[1]))
    else
        println("unknown")
    end
end
process_data() = raw_data |> read_lines .|> parse_instruction
data = process_data()
````

````
7-element Vector{Main.##301.Instruction}:
 Main.##301.CutInstruction(181)
 Main.##301.DealIncrementInstruction(61)
 Main.##301.CutInstruction(-898)
 Main.##301.DealIncrementInstruction(19)
 Main.##301.CutInstruction(-1145)
 Main.##301.DealIncrementInstruction(35)
 Main.##301.CutInstruction(3713)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

