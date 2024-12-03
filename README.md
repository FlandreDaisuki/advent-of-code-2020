# Advent of code 2024

[Homepage](https://adventofcode.com/2024)

Self Challenge: no deps

## bash

```shell
bash-run-aoc() {
  FILENAME="day$1"
  docker run --rm -it -v "$PWD:/app" -w "/app" bash:5.2.37 bash "${FILENAME}.sh"
}

# usage: bash-run-aoc <01|02|03|...|25>
# bash-run-aoc 01
# bash-run-aoc 02
```

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
