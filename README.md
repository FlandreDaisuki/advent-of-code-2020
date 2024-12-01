# Advent of code 2022

[Homepage](https://adventofcode.com/2022)

Self Challenge: no deps

## Build image

```shell
docker build . -t kotlin:1.7.21
```

## Build answers

<!-- cSpell:ignore kotlinc -->
```shell
__build_aoc_kt() {
  FILENAME="day$1"
  docker run --rm -it -v "$PWD:/workspace" kotlin:1.7.21 kotlinc "${FILENAME}.kt" -include-runtime -d "${FILENAME}.jar"
}

# usage: __build_aoc_kt <01|02|03|...|25>
# __build_aoc_kt 01
# __build_aoc_kt 02
```

## Run answers

### kotlin

```shell
__run_aoc_jar() {
  FILENAME="day$1"
  docker run --rm -it -v "$PWD:/workspace" kotlin:1.7.21 java -jar "${FILENAME}.jar"
}

# usage: __run_aoc_jar <01|02|03|...|25>
# __run_aoc_jar 01
# __run_aoc_jar 02
```

### js

```shell
__run_aoc_js() {
  FILENAME="day$1"
  docker run --rm -it -v "$PWD:/node" -w "/node" node:lts-alpine node "${FILENAME}.js"
}

# usage: __run_aoc_js <01|02|03|...|25>
# __run_aoc_js 01
# __run_aoc_js 02
```
