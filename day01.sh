#!/usr/bin/env bash

set -e

FILE_INPUT='day01.txt'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

SORTED_LEFT_COL="$(cut -d ' ' -f 1 "${FILE_INPUT}" | sort)"
SORTED_RIGHT_COL="$(cut -d ' ' -f 4 "${FILE_INPUT}" | sort)"
LC="$(wc -l < "${FILE_INPUT}")"

ANSWER1='0'
for LINE_I in $(seq 1 "${LC}"); do
  LEFT_ITEM="$(echo "${SORTED_LEFT_COL}" | sed -n "${LINE_I}p")"
  RIGHT_ITEM="$(echo "${SORTED_RIGHT_COL}" | sed -n "${LINE_I}p")"
  DIFF="$(( LEFT_ITEM - RIGHT_ITEM ))"
  ABS_DIFF="${DIFF#-}"
  ANSWER1="$(( ANSWER1 + ABS_DIFF ))"
done

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"

ANSWER2='0'

for LINE_I in $(seq 1 "${LC}"); do
  LEFT_ITEM="$(echo "${SORTED_LEFT_COL}" | sed -n "${LINE_I}p")"
  # grep -c will exit non-zero when no matches
  set +e
  FREQ_RIGHT="$(echo "${SORTED_RIGHT_COL}" | grep -c "${LEFT_ITEM}")"
  set -e
  ANSWER2="$(( ANSWER2 + LEFT_ITEM * FREQ_RIGHT ))"
done

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
