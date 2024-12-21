#!/usr/bin/env bash

set -e

FILE_INPUT='day10.txt'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# left top (0, 0)
# hight_grid: `R,C,CHAR`
FLATTEN_HEIGHT_MAP=()
ROW_COUNT="$(wc -l <"${FILE_INPUT}")"
COL_COUNT="$(head -n 1 <"${FILE_INPUT}" | awk '{print length}')"
R=0
while read -r LINE; do
  C=0
  while read -r CHAR; do
    FLATTEN_HEIGHT_MAP+=("${R},${C},${CHAR}")
    C="$((C + 1))"
  done <<<"$(grep -o . <<<"${LINE}")"
  R="$((R + 1))"
done <"${FILE_INPUT}"

# usage: get_higher_hight_grid <HEIGHT_GRID> <FLATTEN_HEIGHT_MAP>
get_higher_hight_grid() {
  local R
  local C
  local H
  R="$(cut -d ',' -f 1 <<<"${1}")"
  C="$(cut -d ',' -f 2 <<<"${1}")"
  H="$(cut -d ',' -f 3 <<<"${1}")"

  local HIGHER_HIGHT_NEIGHBORS
  HIGHER_HIGHT_NEIGHBORS=()

  local TOP
  TOP="$((R - 1)),${C},$((H + 1))"
  if [ "$((R - 1))" -ge 0 ] && grep -q -E "\b${TOP}\b" <<<"${2}"; then
    HIGHER_HIGHT_NEIGHBORS+=("${TOP}")
  fi
  local BOTTOM
  BOTTOM="$((R + 1)),${C},$((H + 1))"
  if [ "$((R + 1))" -le "$((COL_COUNT - 1))" ] && grep -q -E "\b${BOTTOM}\b" <<<"${2}"; then
    HIGHER_HIGHT_NEIGHBORS+=("${BOTTOM}")
  fi
  local LEFT
  LEFT="${R},$((C - 1)),$((H + 1))"
  if [ "$((C - 1))" -ge 0 ] && grep -q -E "\b${LEFT}\b" <<<"${2}"; then
    HIGHER_HIGHT_NEIGHBORS+=("${LEFT}")
  fi
  local RIGHT
  RIGHT="${R},$((C + 1)),$((H + 1))"
  if [ "$((C + 1))" -le "$((ROW_COUNT - 1))" ] && grep -q -E "\b${RIGHT}\b" <<<"${2}"; then
    HIGHER_HIGHT_NEIGHBORS+=("${RIGHT}")
  fi
  echo "${HIGHER_HIGHT_NEIGHBORS[*]}"
}

# usage: get_score <HEIGHT_GRID>
get_score() {
  local X
  local Y
  local H
  X="$(cut -d ',' -f 1 <<<"${1}")"
  Y="$(cut -d ',' -f 2 <<<"${1}")"
  H="$(cut -d ',' -f 3 <<<"${1}")"
  if [ "${H}" != '0' ]; then
    exit 0
  fi

  # BFS
  local TAILS
  local Q
  local CUR

  TAILS=()
  Q=()
  Q+=("${X},${Y},${H}")
  while [ "${#Q[*]}" -gt 0 ]; do
    CUR="${Q[0]}"
    Q=("${Q[@]:1}")

    read -r -a NEIGHBORS <<<"$(get_higher_hight_grid "${CUR}" "${FLATTEN_HEIGHT_MAP[*]}")"

    for HHN in "${NEIGHBORS[@]}"; do
      Q+=("${HHN}")
      if grep -q ",9$" <<<"${HHN}"; then
        TAILS+=("${HHN}")
      fi
    done
  done

  local PATH_COUNT
  PATH_COUNT="$(tr ' ' '\n' <<<"${TAILS[*]}" | sort -u | wc -l)"
  exit "${PATH_COUNT}"
}

PIDS=''
while read -r START; do
  get_score "${START}" &
  PIDS+=" $!"
done <<<"$(tr ' ' '\n' <<<"${FLATTEN_HEIGHT_MAP[*]}" | grep ',0$')"

SCORE=0
read -r -a PID_LIST <<<"${PIDS}"
for PID in "${PID_LIST[@]}"; do
  RET=0
  wait "${PID}" || RET="$?"
  SCORE="$((SCORE + RET))"
done

ANSWER1="${SCORE}"

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"

ANSWER2=""

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
