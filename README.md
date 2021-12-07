# Advent of Code 2020 in Julia

Solutions of annual coding challenge https://adventofcode.com/ written in Julia.

Benchmarks

on my laptop when powered:

|   ∘ | part1_time | part2_time | part1_memory | part2_memory |
| ---:| ----------:| ----------:| ------------:| ------------:|
|   1 | 281.500 μs | 257.500 μs |   192.45 KiB |   176.70 KiB |
|   2 | 483.100 μs | 467.800 μs |   361.81 KiB |   361.81 KiB |
|   3 | 415.500 μs | 444.900 μs |   286.41 KiB |   411.69 KiB |
|   4 | 812.700 μs |   2.486 ms |   398.90 KiB |   898.84 KiB |
|   5 |  17.802 ms |  29.066 ms |    24.87 MiB |    42.25 MiB |
|   6 |  46.500 μs |  48.400 μs |   174.30 KiB |   195.52 KiB |
|   7 | 151.000 μs |   4.046 ms |    88.70 KiB |    30.29 MiB |

## Initialization

Run `python init.py` to generate base parts of the code base for each day.

In order to download the input data programatically, log in to adventofcode.com, and then grab the cookie token and put it to `secret.yaml`.

Make sure you update the `advent-of-code-data` python package using `pip install --upgrade advent-of-code-data`.

Run benchmark using `benchmark.jl`
