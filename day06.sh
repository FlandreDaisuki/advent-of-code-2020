#!/usr/bin/env bash

set -e

FILE_INPUT='day06.txt'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# ABC    ADGJ
# DEF => BEHK
# GHI    CFIL
# JKL
transpose() {
  # shellcheck disable=SC2001
  sed 's/\(.\)/\1 /g' <<<"${1}" |
    awk '
    {
      for(f = 1; f <= NF; f++) {
        matrix[f, NR] = $f
        width = NF
      }
      height += 1
    }
    END {
      for(r = 1; r <= width; r++) {
        for(c = 1; c <= height; c++) {
          printf("%s", matrix[r, c])
        }
        print ""
      }
    }'
}

rotate90() {
  transpose "${1}" | rev
}

rotate-90() {
  transpose "$(rev <<<"${1}")"
}

debug_map() {
  echo -e "${1}" >&2
  read -r
}

INIT_MAP="$(cat "${FILE_INPUT}")"
MUT_MAP="$(rotate90 "${INIT_MAP}" | sed 's/\^/>/g')"

# debug_map "${MUT_MAP}"
while grep -q '>.*#' <<<"${MUT_MAP}"; do
  MATCHED="$(grep -E -o '>[^#]*#' <<<"${MUT_MAP}")"
  FOOTPRINT="$(sed -E 's/[^#]/x/g' <<<"${MATCHED}" | sed 's/x#/>#/')"
  WALKED="${MUT_MAP//"${MATCHED}"/"${FOOTPRINT}"}"
  # debug_map "${WALKED}"
  MUT_MAP="$(rotate-90 "${WALKED}")"
  # debug_map "${MUT_MAP}"
done

FINAL_MATCHED="$(grep -E -o '>.*$' <<<"${MUT_MAP}")"
FINAL_FOOTPRINT="$(sed -E 's/./x/g' <<<"${FINAL_MATCHED}")"
FINAL_WALKED="${MUT_MAP//"${FINAL_MATCHED}"/"${FINAL_FOOTPRINT}"}"
# debug_map "${FINAL_WALKED}"

ANSWER1="$(grep -o 'x' <<<"${FINAL_WALKED}" | wc -l)"

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"

ANSWER2=""

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
