# Advent of Code 2020 in Julia

Solutions of annual coding challenge https://adventofcode.com/ written in Julia.

Benchmarks

on my laptop when powered:

|   ∘ | part1_time | part2_time | part1_memory | part2_memory |
| ---:| ----------:| ----------:| ------------:| ------------:|
|   1 | 210.300 μs | 216.400 μs |   192.53 KiB |   176.78 KiB |
|   2 | 371.100 μs | 370.200 μs |   361.81 KiB |   361.81 KiB |
|   3 | 318.600 μs | 354.400 μs |   286.53 KiB |   411.77 KiB |
|   4 | 694.800 μs |   1.917 ms |   398.90 KiB |   898.84 KiB |
|   5 |  14.354 ms |  23.607 ms |    24.87 MiB |    42.25 MiB |
|   6 |  38.800 μs |  39.400 μs |   174.38 KiB |   195.59 KiB |
|   7 | 121.400 μs |   1.443 ms |    81.03 KiB |   221.41 KiB |
|   8 |   1.011 ms |   7.949 ms |   882.02 KiB |     7.19 MiB |
|   9 |   1.508 ms |  10.225 ms |     1.23 MiB |     7.46 MiB |
|  10 | 223.200 μs | 368.700 μs |   403.48 KiB |   605.75 KiB |
|  11 | 650.000 μs |   1.913 ms |   425.30 KiB |     1.08 MiB |
|  12 |  39.067 ms |   12.527 s |    22.09 MiB |    31.73 GiB |
|  13 | 860.000 μs |   1.693 ms |   650.64 KiB |     1.02 MiB |
|  14 | 747.800 μs |   3.190 ms |   584.67 KiB |     2.48 MiB |

## Initialization

Run `python init.py` to generate base parts of the code base for each day.

In order to download the input data programatically, log in to adventofcode.com, and then grab the cookie token and put it to `secret.yaml`.

Make sure you update the `advent-of-code-data` python package using `pip install --upgrade advent-of-code-data`.

Run benchmark using `benchmark.jl`
