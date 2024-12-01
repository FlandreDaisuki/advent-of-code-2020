# Advent of code 2024

[Homepage](https://adventofcode.com/2024)

Self Challenge: no deps

## js

```shell
bun-run-aoc() {
  FILENAME="day$1"
  docker run --rm -it -v "$PWD:/app" -w "/app" oven/bun:1.1.38-alpine bun "${FILENAME}.js"
}


# usage: bun-run-aoc <01|02|03|...|25>
# bun-run-aoc 01
# bun-run-aoc 02
```
