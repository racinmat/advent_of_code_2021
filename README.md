# Advent of Code 2020 in Julia

Solutions of annual coding challenge https://adventofcode.com/ written in Julia.

Benchmarks

|   ∘ | part1_time | part2_time | part1_memory | part2_memory |
| ---:| ----------:| ----------:| ------------:| ------------:|
|   1 | 208.800 μs | 214.100 μs |   192.45 KiB |   176.70 KiB |
|   2 | 366.700 μs | 367.500 μs |   361.81 KiB |   361.81 KiB |
|   3 | 316.800 μs | 353.800 μs |   286.50 KiB |   411.77 KiB |
|   4 | 674.200 μs |   1.919 ms |   398.90 KiB |   898.84 KiB |
|   5 |  12.893 ms |  20.852 ms |    24.87 MiB |    42.26 MiB |

## Initialization

Run `python init.py` to generate base parts of the code base for each day.

In order to download the input data programatically, log in to adventofcode.com, and then grab the cookie token and put it to `secret.yaml`.

Make sure you update the `advent-of-code-data` python package using `pip install --upgrade advent-of-code-data`.

Run benchmark using `benchmark.jl`
