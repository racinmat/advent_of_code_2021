# Advent of Code 2020 in Julia

Solutions of annual coding challenge https://adventofcode.com/ written in Julia.

Benchmarks

|   ∘ | part1_time | part2_time | part1_memory | part2_memory |
| ---:| ----------:| ----------:| ------------:| ------------:|
|   1 | 208.100 μs | 268.100 μs |   192.45 KiB |   332.80 KiB |

## Initialization

Run `python init.py` to generate base parts of the code base for each day.
In order to download the input data programatically, log in to adventofcode.com, and then grab the cookie token and put it to `secret.yaml`.
Make sure you update the `advent-of-code-data` python package using `pip install --upgrade advent-of-code-data`.
Run benchmark using `benchmark.jl`
