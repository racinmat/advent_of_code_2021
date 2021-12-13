# Advent of Code 2020 in Julia

Solutions of annual coding challenge https://adventofcode.com/ written in Julia.

Benchmarks

on my laptop when powered:

|   ∘ | part1_time | part2_time | part1_memory | part2_memory |
| ---:| ----------:| ----------:| ------------:| ------------:|
|   1 | 214.300 μs | 214.700 μs |   192.45 KiB |   176.70 KiB |
|   2 | 368.700 μs | 369.400 μs |   361.81 KiB |   361.81 KiB |
|   3 | 318.800 μs | 354.200 μs |   286.53 KiB |   411.77 KiB |
|   4 | 689.300 μs |   1.878 ms |   398.90 KiB |   898.84 KiB |
|   5 |  13.836 ms |  22.798 ms |    24.87 MiB |    42.25 MiB |
|   6 |  37.700 μs |  38.000 μs |   174.30 KiB |   195.52 KiB |
|   7 | 121.700 μs |   1.407 ms |    81.03 KiB |   221.41 KiB |
|   8 |   1.009 ms | 134.227 ms |   883.84 KiB |   138.43 MiB |
|   9 |   1.391 ms |   9.889 ms |     1.23 MiB |     7.46 MiB |
|  10 | 224.600 μs | 362.800 μs |   403.48 KiB |   605.75 KiB |
|  11 |   4.006 ms |  10.810 ms |     3.00 MiB |     7.92 MiB |
|  12 |  40.301 ms |   13.694 s |    22.09 MiB |    31.73 GiB |
|  13 |   1.327 ms |   6.814 ms |   659.53 KiB |     1.12 MiB |

## Initialization

Run `python init.py` to generate base parts of the code base for each day.

In order to download the input data programatically, log in to adventofcode.com, and then grab the cookie token and put it to `secret.yaml`.

Make sure you update the `advent-of-code-data` python package using `pip install --upgrade advent-of-code-data`.

Run benchmark using `benchmark.jl`
