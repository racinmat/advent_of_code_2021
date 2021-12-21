# Advent of Code 2020 in Julia

Solutions of annual coding challenge https://adventofcode.com/ written in Julia.

Benchmarks

on my laptop when powered:

|   ∘ | part1_time | part2_time | part1_memory | part2_memory |
| ---:| ----------:| ----------:| ------------:| ------------:|
|   1 | 260.500 μs | 222.900 μs |   192.53 KiB |   176.78 KiB |
|   2 | 369.800 μs | 388.200 μs |   361.81 KiB |   361.81 KiB |
|   3 | 327.100 μs | 414.500 μs |   286.22 KiB |   411.45 KiB |
|   4 | 692.500 μs |   2.281 ms |   398.90 KiB |   898.84 KiB |
|   5 |  15.180 ms |  26.643 ms |    24.87 MiB |    42.25 MiB |
|   6 |  50.700 μs |  49.800 μs |   173.62 KiB |   194.84 KiB |
|   7 | 141.500 μs | 744.700 μs |    77.03 KiB |    67.03 KiB |
|   8 |   1.213 ms |   5.928 ms |   882.02 KiB |     7.12 MiB |
|   9 |   1.457 ms |  10.350 ms |     1.21 MiB |     7.44 MiB |
|  10 | 236.700 μs | 424.300 μs |   403.48 KiB |   605.75 KiB |
|  11 | 737.200 μs |   2.149 ms |   425.30 KiB |     1.08 MiB |
|  12 |  18.544 ms | 938.647 ms |    12.30 MiB |   380.07 MiB |
|  13 |   1.066 ms |   2.203 ms |   650.61 KiB |     1.02 MiB |
|  14 | 875.800 μs |   3.908 ms |   584.67 KiB |     2.48 MiB |
|  15 |  66.056 ms |    3.892 s |    71.29 MiB |     1.79 GiB |
|  16 | 396.200 μs | 385.100 μs |   370.19 KiB |   370.19 KiB |
|  17 | 134.972 ms | 284.773 ms |    22.27 MiB |    69.13 MiB |
|  18 | 115.751 ms |    1.238 s |    18.19 MiB |   286.90 MiB |
|  19 | 783.274 ms | 783.647 ms |   638.62 MiB |   638.63 MiB |
|  20 |   2.833 ms | 150.502 ms |     1.90 MiB |   126.58 MiB |
|  21 |  49.800 μs |   1.250 μs |    37.81 KiB |     1.17 KiB |

on server: `~/julia-1.7.0/bin/julia benchmark.jl`

|   ∘ | part1_time | part2_time | part1_memory | part2_memory |
| ---:| ----------:| ----------:| ------------:| ------------:|
|   1 | 223.001 μs | 225.162 μs |   192.53 KiB |   176.78 KiB |
|   2 | 357.692 μs | 360.488 μs |   361.81 KiB |   361.81 KiB |
|   3 | 341.626 μs | 398.994 μs |   286.22 KiB |   411.45 KiB |
|   4 | 721.525 μs |   2.246 ms |   398.90 KiB |   898.84 KiB |
|   5 |  16.035 ms |  27.767 ms |    24.87 MiB |    42.25 MiB |
|   6 |  43.990 μs |  42.068 μs |   173.62 KiB |   194.84 KiB |
|   7 | 126.906 μs | 849.646 μs |    77.03 KiB |    67.03 KiB |
|   8 | 976.151 μs |   6.092 ms |   882.02 KiB |     7.12 MiB |
|   9 |   1.444 ms |  10.428 ms |     1.21 MiB |     7.44 MiB |
|  10 | 200.359 μs | 325.867 μs |   403.48 KiB |   605.75 KiB |
|  11 | 792.696 μs |   2.333 ms |   425.30 KiB |     1.08 MiB |
|  12 |  16.302 ms | 661.940 ms |    12.30 MiB |   380.07 MiB |
|  13 | 980.855 μs |   1.518 ms |   650.61 KiB |     1.02 MiB |
|  14 | 769.565 μs |   3.205 ms |   584.67 KiB |     2.48 MiB |
|  15 |  77.785 ms |    4.328 s |    71.29 MiB |     1.79 GiB |
|  16 | 427.188 μs | 429.911 μs |   370.19 KiB |   370.19 KiB |
|  17 | 112.855 ms | 277.408 ms |    22.27 MiB |    69.13 MiB |


## Initialization

Run `python init.py` to generate base parts of the code base for each day.

In order to download the input data programatically, log in to adventofcode.com, and then grab the cookie token and put it to `secret.yaml`.

Make sure you update the `advent-of-code-data` python package using `pip install --upgrade advent-of-code-data`.

Run benchmark using `benchmark.jl`
