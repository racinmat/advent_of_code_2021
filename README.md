# Advent of Code 2020 in Julia

Solutions of annual coding challenge https://adventofcode.com/ written in Julia.

Benchmarks

|   ∘ | part1_time | part2_time | part1_memory | part2_memory |
| ---:| ----------:| ----------:| ------------:| ------------:|
|   1 | 209.400 μs | 210.800 μs |   192.45 KiB |   176.70 KiB |
|   2 | 378.900 μs | 369.800 μs |   361.81 KiB |   361.81 KiB |
|   3 | 319.400 μs | 357.900 μs |   286.53 KiB |   411.77 KiB |
|   4 | 682.800 μs |   1.903 ms |   398.90 KiB |   898.84 KiB |
|   5 |  14.233 ms |  23.637 ms |    24.87 MiB |    42.26 MiB |
|   6 |  46.600 μs |  49.300 μs |   185.89 KiB |   208.52 KiB |

## Initialization

Run `python init.py` to generate base parts of the code base for each day.

In order to download the input data programatically, log in to adventofcode.com, and then grab the cookie token and put it to `secret.yaml`.

Make sure you update the `advent-of-code-data` python package using `pip install --upgrade advent-of-code-data`.

Run benchmark using `benchmark.jl`
