# Advent of Code 2020 in Julia

Solutions of annual coding challenge https://adventofcode.com/ written in Julia.

Benchmarks

on my laptop when powered:

|   ∘ | part1_time | part2_time | part1_memory | part2_memory |
| ---:| ----------:| ----------:| ------------:| ------------:|
|   1 | 213.800 μs | 214.300 μs |   192.45 KiB |   176.70 KiB |
|   2 | 379.100 μs | 373.200 μs |   361.81 KiB |   361.81 KiB |
|   3 | 328.800 μs | 364.700 μs |   286.41 KiB |   411.69 KiB |
|   4 | 692.500 μs |   1.975 ms |   398.90 KiB |   898.84 KiB |
|   5 |  14.494 ms |  24.506 ms |    24.87 MiB |    42.25 MiB |
|   6 |  39.300 μs |  41.300 μs |   174.30 KiB |   195.52 KiB 

## Initialization

Run `python init.py` to generate base parts of the code base for each day.

In order to download the input data programatically, log in to adventofcode.com, and then grab the cookie token and put it to `secret.yaml`.

Make sure you update the `advent-of-code-data` python package using `pip install --upgrade advent-of-code-data`.

Run benchmark using `benchmark.jl`
