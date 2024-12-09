#!/usr/bin/env bash

set -e

FILE_INPUT='day02.txt'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# ref: https://www.cyberciti.biz/faq/how-to-trim-leading-and-trailing-white-space-in-bash/
trim_all_white_spaces_cmd() {
  read -r -a ARGS <<<"$*"
  printf '%s\n' "${ARGS[*]}"
}

to_asc_sorted_cmd() {
  echo -n "${1}" | tr ' ' $'\n' | sort -n | tr $'\n' ' ' | awk '{$1=$1};1'
}

to_desc_sorted_cmd() {
  echo -n "${1}" | tr ' ' $'\n' | sort -n -r | tr $'\n' ' ' | awk '{$1=$1};1'
}

is_sorted() {
  local LINE
  while read -r LINE; do
    local ASC_ORDER
    ASC_ORDER="$(to_asc_sorted_cmd "${LINE}")"
    local DESC_ORDER
    DESC_ORDER="$(to_desc_sorted_cmd "${LINE}")"
    if [ "${ASC_ORDER}" = "${LINE}" ]; then
      echo "${LINE}"
    elif [ "${DESC_ORDER}" = "${LINE}" ]; then
      echo "${LINE}"
    fi
  done
}

is_strictly_monotone() {
  local LINE
  while read -r LINE; do
    local ASC_ORDER
    ASC_ORDER="$(to_asc_sorted_cmd "${LINE}")"
    awk '
    function abs(x) { return x < 0 ? -x : x }
    {
      p=$1
      for(i=2; i<=NF; i++) {
        if(abs($i - p) > 3 || abs($i - p) == 0) {
          $0=""
        }
        p=$i
      }
      print $0
    }' <<<"${ASC_ORDER}"
  done
}

ANSWER1="$(
  while read -r LINE; do echo "$LINE"; done <"${FILE_INPUT}" |
    is_sorted |
    sed '/^$/d' |
    is_strictly_monotone |
    sed '/^$/d' |
    wc -l
)"

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"

is_sorted_cmd() {
  local RESULT
  RESULT="$(is_sorted <<<"${1}")"
  [ -n "${RESULT}" ]
}

is_strictly_monotone_cmd() {
  local RESULT
  RESULT="$(is_strictly_monotone <<<"${1}")"
  [ -n "${RESULT}" ]
}

is_tolerable() {
  local LINE
  while read -r LINE; do
    if is_sorted_cmd "${LINE}" && is_strictly_monotone_cmd "${LINE}"; then
      echo "${LINE}"
    else
      local LEN
      LEN="$(wc -w <<<"${LINE}")"
      for ITEM_I in $(seq 1 "${LEN}"); do
        ONE_RID_OFF="$(trim_all_white_spaces_cmd "$(awk "{\$${ITEM_I}=\"\";print}" <<<"${LINE}")")"
        if is_sorted_cmd "${ONE_RID_OFF}" && is_strictly_monotone_cmd "${ONE_RID_OFF}"; then
          echo "${LINE}"
          break
        fi
      done
    fi
  done
}

ANSWER2="$(
  while read -r LINE; do echo "$LINE"; done <"${FILE_INPUT}" |
    is_tolerable |
    wc -l
)"

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
