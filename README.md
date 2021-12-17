# Advent of Code 2020 in Julia

Solutions of annual coding challenge https://adventofcode.com/ written in Julia.

Benchmarks

on my laptop when powered:

|   ∘ | part1_time | part2_time | part1_memory | part2_memory |
| ---:| ----------:| ----------:| ------------:| ------------:|
|   1 | 240.900 μs | 227.300 μs |   192.53 KiB |   176.78 KiB |
|   2 | 443.900 μs | 516.500 μs |   361.81 KiB |   361.81 KiB |
|   3 | 400.800 μs | 468.900 μs |   286.09 KiB |   411.38 KiB |
|   4 | 816.900 μs |   2.470 ms |   398.90 KiB |   898.84 KiB |
|   5 |  16.177 ms |  27.190 ms |    24.87 MiB |    42.25 MiB |
|   6 |  50.700 μs |  40.000 μs |   173.62 KiB |   194.84 KiB |
|   7 | 124.800 μs | 821.200 μs |    77.03 KiB |    67.03 KiB |
|   8 |   1.277 ms |   6.486 ms |   882.02 KiB |     7.12 MiB |
|   9 |   1.775 ms |   8.239 ms |     1.21 MiB |     6.92 MiB |
|  10 | 295.700 μs | 480.600 μs |   403.48 KiB |   605.75 KiB |
|  11 | 804.900 μs |   2.286 ms |   425.30 KiB |     1.08 MiB |
|  12 |  17.467 ms | 759.847 ms |    12.30 MiB |   380.07 MiB |
|  13 | 948.200 μs |   2.155 ms |   650.61 KiB |     1.02 MiB |
|  14 | 796.500 μs |   3.582 ms |   584.67 KiB |     2.48 MiB |
|  15 |  59.262 ms |    4.102 s |    71.29 MiB |     1.79 GiB |
|  16 | 312.700 μs | 305.300 μs |   370.19 KiB |   370.19 KiB |
|  17 | 112.035 ms | 282.692 ms |    22.27 MiB |    69.13 MiB |

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
