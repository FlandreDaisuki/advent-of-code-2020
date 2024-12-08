#!/usr/bin/env bash

set -e

FILE_INPUT='day03.txt'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

ANSWER1="$(
  grep -E -o 'mul\([0-9]+,[0-9]+\)' "${FILE_INPUT}" \
  | sed 's/mul(\([0-9]\+\),\([0-9]\+\))/\1*\2/g' \
  | bc \
  | awk '{sum+=$1} END {print sum}'
)"

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"


ANSWER2="$(
  grep -E -o '(do\(\)|don\x27t\(\)|mul\([0-9]+,[0-9]+\))' "${FILE_INPUT}" \
  | awk 'BEGIN{f=1} /do()/ {f=1} /don\x27t()/ {f=0} f' \
  | grep mul \
  | sed 's/mul(\([0-9]\+\),\([0-9]\+\))/\1*\2/g' \
  | bc \
  | awk '{sum+=$1} END {print sum}'
)"

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
