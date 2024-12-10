#!/usr/bin/env bash

set -e

# FILE_INPUT='day06.txt'
FILE_INPUT='day06.s.txt'
YELLOW='\033[0;33m'
RED='\033[0;31m'
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
  H="${2:-z}"
  (echo -e "${1//${H}/${RED}${H}${NC}}") >&2
  echo >&2
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
debug_map "${FINAL_WALKED}"

ANSWER1="$(grep -o 'x' <<<"${FINAL_WALKED}" | wc -l)"

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"

# (-y, x, 1(mod 4))
#                    │.............INIT_MAP x r90
#                ^   │            .
#                    │      (x, y, 0(mod 4))
#                    │     >      .
#                    │            .
#                    │            .
# ───────────────────┼────────────────────
#                    │
#                    │
#              <     │
# (-x, -y, 2(mod 4)) │
#                    │   v (y, -x, 3(mod 4))
#                    │

# usage: get_coord <MAP> <ROTATE_COUNT>
get_coord() {
  local MAP
  MAP="${1}"
  local ROTATE_COUNT
  ROTATE_COUNT="${2}"
  local HEIGHT
  HEIGHT="$(wc -l <<<"${MAP}")"
  local WIDTH
  WIDTH="$(awk '{print length($0); exit}' <<<"${MAP}")"

  local TOP
  local LEFT
  TOP="$(awk '/>/ {print NR}' <<<"${MAP}")"
  LEFT="$(grep -o '.*>' <<<"${MAP}" | awk '{print length}')"

  case "$((ROTATE_COUNT % 4))" in
  0)
    echo "${LEFT},$((HEIGHT - TOP + 1))"
    ;;
  1)
    echo "$((WIDTH - TOP + 1)),$((HEIGHT - LEFT + 1))"
    ;;
  2)
    echo "$((WIDTH - LEFT + 1)),${TOP}"
    ;;
  3)
    echo "${TOP},${LEFT}"
    ;;
  *)
    echo "IMPOSSIBLE STATE!!" >&2
    exit 255
    ;;
  esac
}

INIT_MAP="$(cat "${FILE_INPUT}")"
MUT_MAP="$(rotate90 "${INIT_MAP}" | sed 's/\^/>/g')"
ROTATE_COUNT=0
VISITED_COORD="$(get_coord "${MUT_MAP}" "${ROTATE_COUNT}")"

echo "VISITED_COORD [${VISITED_COORD}]"
debug_map "${MUT_MAP}" '>'
while grep -q '>.*#' <<<"${MUT_MAP}"; do
  MATCHED="$(grep -E -o '>[^#]*#' <<<"${MUT_MAP}")"
  FOOTPRINT="$(sed -E 's/[^#]/x/g' <<<"${MATCHED}" | sed 's/x#/>#/')"
  WALKED="${MUT_MAP//"${MATCHED}"/"${FOOTPRINT}"}"
  VISITED_COORD+=" $(get_coord "${WALKED}" "${ROTATE_COUNT}")"

  echo "VISITED_COORD [${VISITED_COORD}]"
  debug_map "${WALKED}" '>'
  MUT_MAP="$(rotate-90 "${WALKED}")"
  ROTATE_COUNT="$((ROTATE_COUNT + 1))"
  debug_map "${MUT_MAP}"
done

FINAL_MATCHED="$(grep -E -o '>.*$' <<<"${MUT_MAP}")"
FINAL_FOOTPRINT="$(sed -E 's/./x/g' <<<"${FINAL_MATCHED}" | sed 's/.$/>/')"
FINAL_WALKED="${MUT_MAP//"${FINAL_MATCHED}"/"${FINAL_FOOTPRINT}"}"
VISITED_COORD+=" $(get_coord "${FINAL_WALKED}" "${ROTATE_COUNT}")"

echo "VISITED_COORD [${VISITED_COORD}]"
debug_map "${FINAL_WALKED}" '>'

# 五座標的第四向量逐一檢查
# 若第四向量有一點 x 其 x 的右轉向量有 # 且可以與之前軌跡的向量重疊，則 x 為交點
ANSWER2=""

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
